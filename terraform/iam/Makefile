secret.tfvars:
	touch secrets.tfvars
init:
	terraform init
fmt:
	terraform fmt

plan: secret.tfvars
	terraform plan -var-file=secrets.tfvars
apply: secret.tfvars
	terraform apply -var-file=secrets.tfvars

test:
	aws --profile suna-terraform-role sts get-caller-identity
