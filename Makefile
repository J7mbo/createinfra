## Public Targets
plan: --init --get ## View the Terraform plan for what would be created on DigitalOcean
	TERRAFORM_COMMAND="plan" docker compose up terraform
provision: --init --get ## Provision the nodes on DigitalOcean
	TERRAFORM_COMMAND="apply -auto-approve" docker compose up terraform
destroy: ## Destroy the nodes on DigitalOcean
	TERRAFORM_COMMAND="destroy -auto-approve" docker compose up terraform

## Private Targets -- is a convention
--init:
	TERRAFORM_COMMAND="init" docker-compose up terraform
--get:
	TERRAFORM_COMMAND="get" docker-compose up terraform

## Help! The default target
help: ## Print the help
	@echo 'Usage: make [target] ...'
	@echo
	@echo 'targets:'
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

.DEFAULT_GOAL := help