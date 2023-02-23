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