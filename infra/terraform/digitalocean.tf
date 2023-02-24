/*
  High level project config and access token.
  See: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project
*/
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_project" "digitalocean_project" {
  name        = var.DIGITALOCEAN_PROJECT_NAME
  environment = "Production"
  resources   = concat(
    // All digitalocean droplets come from droplets.tf.
    [for droplet in digitalocean_droplet.droplets : droplet.urn]
  )
}

/*
  This token can automagically be used by Terraform according to: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs, however probably best to be explicit here so we know where the token comes from and where it's going.
*/
provider "digitalocean" {
  token = var.DIGITALOCEAN_ACCESS_TOKEN
}

#/*
#  Uses the output of the ssh_key_pair module defined in modules.tf.
#*/
#resource "digitalocean_ssh_key" "ssh_key" {
#  name                       = var.DIGITALOCEAN_PROJECT_NAME
#  public_key                 = module.ssh_key_pair.public_key
#  private_key_output_enabled = "true"
#}


#/*
#  On-destroy of the droplet, use ssh-keygen -R to remove the IP from known hosts so we've back to a clean slate.
#  The uuid, constant and locals is because: https://github.com/hashicorp/terraform/issues/23679#issuecomment-886020367
#*/
#resource "null_resource" "remove_known_hosts" {
#  for_each = digitalocean_droplet.droplets
#
#  triggers = {
#    ipv4_address = each.value.ipv4_address
#  }
#
#  provisioner "local-exec" {
#    when       = destroy
#    on_failure = continue
##    command = "ssh-keygen -R ${self.triggers.ipv4_address} || true"
##    command    = "ssh-keygen -R ${each.value.ipv4_address} || true"
#
#  }
#}