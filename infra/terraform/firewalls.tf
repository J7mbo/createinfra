/*
  Firewalls on DigitalOcean - only allow traffic through these ports.
*/
resource "digitalocean_firewall" "ssh" {
  name        = "ssh"
  droplet_ids = [for droplet in digitalocean_droplet.droplets : droplet.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}

/*
  The firewall lets us call anything that we want to outbound.
*/
resource "digitalocean_firewall" "outbound" {
  name = "outbound"

  droplet_ids = [ for droplet in digitalocean_droplet.droplets: droplet.id ]

  outbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol         = "udp"
    port_range       = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}