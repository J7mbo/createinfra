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

/*
  This firewall allows docker-swarm to communicate between nodes.
*/
resource "digitalocean_firewall" "swarm" {
  name = "swarm"

  droplet_ids = [ for droplet in digitalocean_droplet.droplets: droplet.id ]

  // 2376 is for docker-machine to talk to.
  // 2377 is for communication between swarm nodes - only needs to be on manager.
  // 7946 is for swarm container network discovery.
  // 4789 is for overlay network traffic.
  inbound_rule {
    protocol         = "tcp"
    port_range       = "2376-2377"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "7946"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "7946"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "4789"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}