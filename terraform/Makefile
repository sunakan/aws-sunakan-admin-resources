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
	aws --profile suna-sunabako-OrganizationAccountAccessRole sts get-caller-identity
	aws --profile suna-development-OrganizationAccountAccessRole sts get-caller-identity
	aws --profile suna-shared-OrganizationAccountAccessRole sts get-caller-identity

default-vpc:
	VPC_IDS=$( \
    aws --profile suna-development-OrganizationAccountAccessRole \
    ec2 describe-vpcs --filters "Name=isDefault,Values=true" \
    --query "Vpcs[].VpcId" \
    --output text \
  ) && echo ${VPC_IDS}
