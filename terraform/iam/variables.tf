################################################################################
#
################################################################################
variable "organizations_master_account_suna_terraform_role_arn" {
  description = "OrganizationsのマスターアカウントのAdmin権限をもったロールのARN"
  type        = string
  default     = "arn:aws:iam::xxxxxxxxxxxx:role/xxx-terraform"
}
