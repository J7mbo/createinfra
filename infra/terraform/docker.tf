locals {
  managerDropletName = digitalocean_droplet.droplets[one([for k, v in var.NODES : k if v.tag == "manager"])].name
}

/*
  Use a module to run a command to create a docker swarm on the manager node and get the join token as an output to pass to workers.
*/
module "docker_swarm_managers" {
  source  = "Invicton-Labs/shell-data/external"
  for_each = {for key, value in digitalocean_droplet.droplets: key => value if contains(value.tags, "manager")}

  command_unix = "ssh -q -o StrictHostKeyChecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i ${var.SSH_KEY_DIR}/${var.DIGITALOCEAN_PROJECT_NAME}-${each.value.name} root@${each.value.ipv4_address} \"docker swarm init --advertise-addr ${each.value.ipv4_address}\" | grep \"docker swarm join --token\" | grep -v grep | grep -v Warning"

  // When we re-create or destroy the droplet, ignore it complaining that it's already in a swarm / swarm manager has gone.
  fail_on_nonzero_exit_code = false
}

/*
  Uses the output of docker_swarm_managers (module above), which is grepped to contain only "docker swarm join --token <token> <IP>:<Port>" as the command to run on each worker to tell them to join the swarm.
*/
module "docker_swarm_workers" {
  source  = "Invicton-Labs/shell-data/external"
  for_each = {for key, value in digitalocean_droplet.droplets: key => value if contains(value.tags, "worker")}

  command_unix = "ssh -o StrictHostKeyChecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i ${var.SSH_KEY_DIR}/${var.DIGITALOCEAN_PROJECT_NAME}-${each.value.name} root@${each.value.ipv4_address} \"${module.docker_swarm_managers[local.managerDropletName].stdout}\""

  // When we re-create or destroy the droplet, ignore it complaining that it's already in a swarm / swarm manager has gone.
  fail_on_nonzero_exit_code = false
}