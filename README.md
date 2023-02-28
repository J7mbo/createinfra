Create Infra
--

Deploying from scratch a Go application with TLS to a domain you have purchased.
Progression is through using terraform, ansible, letsencrypt, docker swarm, traefik, a VPN, openLDAP, Kibana, your own two-factor authentication and more!

Created more for me for future projects that I have built to deploy efficiently. Maybe you will find it useful.

You can follow this step-by-step by switching branches as each one builds upon the previous one.

---

| Step                                                                                                                                                       |                  Doc                  |
|------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------:|
| <details><summary>01. Terraform Nodes</summary>Using Terraform simply to spin up some nodes on digital ocean which we will eventually deploy to.</details> | [01](docs/01.%20Terraform%20Nodes.md) |
| <details><summary>02. Terraform SSH</summary>Using Terraform to configure firewall rules and allow access to nodes via an SSH Key.</details>               |  [02](docs/02.%20Terraform%20SSH.md)  |
| <details><summary>03. Docker Swarm</summary>Using Terraform to install docker and set up docker swarm.</details>                                           |  [03](docs/03.%20Docker%20Swarm.md)   |