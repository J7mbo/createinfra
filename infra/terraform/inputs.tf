/*
  File to handle all variables the user needs to provide to use this Terraform script.

  If you try and use Terraform from the command line, you will be automatically asked to type in these variables.
  If you provide environment variables (e.g. TF_VAR_DIGITALOCEAN_PROJECT_NAME), no questions will be asked.
*/
variable "DIGITALOCEAN_PROJECT_NAME" {
  type        = string
  description = "The name of the project - used when creating the project in digitalocean"
}

variable "DIGITALOCEAN_REGION" {
  type        = string
  description = "The datacenter region for all digitalocean droplets"
}

variable "DIGITALOCEAN_ACCESS_TOKEN" {
  type        = string
  description = "The access token for digital ocean - available from your dashboard"
}

variable "NODES" {
  type = map(object({
    image = string
    size  = string
    tag   = string
  }))
  description = "A map of objects, with the key being the name of the node, to spin up"
}

variable "SSH_KEY_DIR" {
  type        = string
  description = "The ssh directory, typically /Users/<your_username>/.ssh (only absolute directories work here)"
}