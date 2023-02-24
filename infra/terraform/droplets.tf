locals {
  /*
    Droplets to be spun up, their name and the image.
    Place all droplets here. They will be spun up in a loop within digitalocean_droplet.droplets.
  */
  droplets = {
    (var.DIGITALOCEAN_DROPLET_NAME) : {
      image = var.DIGITALOCEAN_DISTRO_IMAGE
      size  = var.DIGITALOCEAN_DROPLET_SIZE
    }
  }
}

/*
  Loop around 'droplets' defined above (see for_each) to spin up droplets.
  See: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet
*/
resource "digitalocean_droplet" "droplets" {
  for_each = local.droplets
  name     = each.key
  region   = var.DIGITALOCEAN_REGION
  image    = each.value.image
  size     = each.value.size
  tags     = [each.key]
  // Find the module-generated ssh key with the same name as the droplet being created and use that.
  ssh_keys = toset([
    for key in digitalocean_ssh_key.ssh_keys: key.id
      if key.name == "${var.DIGITALOCEAN_PROJECT_NAME}-${each.key}"
  ])
}

/*
  This is the resource that digitalocean_droplet needs for it's ssh keys.
  This is a list that is based on the output of the module `ssh_key_pair`, which actually generates the files, below.
*/
resource "digitalocean_ssh_key" "ssh_keys" {
  for_each = module.ssh_key_pair
  name       = each.value.key_name
  public_key = each.value.public_key
}

/*
  Use the ssh_key_pair module to generate a key for each droplet, with the key name being the project name + droplet name (the key in the droplets array in locals above).

  For example, this will create the private key at: "/Users/james/.ssh/createinfra-mainnode"
*/
module "ssh_key_pair" {
  for_each = local.droplets

  source              = "git::https://github.com/cloudposse/terraform-tls-ssh-key-pair.git?ref=master"
  ssh_public_key_path = var.SSH_KEY_DIR
  name                = "${var.DIGITALOCEAN_PROJECT_NAME}-${each.key}"
}

/*
  If you have SSHd into a node, it's IP Address be added to your known_hosts file. When droplets are destroyed, remove it from your known_hosts file (typically ~/.ssh/known_hosts).
*/
resource "null_resource" "remove_known_hosts" {
  for_each = digitalocean_droplet.droplets

  triggers = {
    ipv4_address    = each.value.ipv4_address
    private_key_dir = var.SSH_KEY_DIR
  }

  /* When destroying multiple droplets quickly, it looks like there is a race condition with the ssh-keygen command which causes the known_hosts.old file to not be writeable, possibly due to using docker for terraform, giving a "link" error. To avoid this, we use a retry + timeout until removing the IP from the known_hosts file is successful.

    If you remove the wait time part and just set the command to be ssh-keygen, you'll note that in the case of two droplets that you've SSHd into being destroyed, one of their IPs will still be in known_hosts afterwards.
  */
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      NEXT_WAIT_TIME=0
      until [ $NEXT_WAIT_TIME -eq 5 ] || ssh-keygen -f ${self.triggers.private_key_dir}/known_hosts -R ${self.triggers.ipv4_address}; do
          sleep $(( NEXT_WAIT_TIME++ ))
      done
      [ $NEXT_WAIT_TIME -lt 5 ]
    EOT
  }
}