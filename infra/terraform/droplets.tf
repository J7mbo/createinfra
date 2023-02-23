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
}


