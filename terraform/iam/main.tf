################################################################################
# 自分情報
################################################################################
data "aws_caller_identity" "master" {}
################################################################################
# OrganizationAccountAccessRole
# It is created by AWS Organizations
#   - 1st. Require `terraform import` command because it is created in default
#   - 2nd. Change identifers from root
################################################################################
data "aws_iam_policy_document" "organization_account_access_principals" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.organizations_master_account_suna_terraform_role_arn]
    }
  }
}
resource "aws_iam_role" "suna_development_organization_account_access_role" {
  provider           = aws.suna_development
  name               = "OrganizationAccountAccessRole"
  assume_role_policy = data.aws_iam_policy_document.organization_account_access_principals.json
}
resource "aws_iam_role" "suna_shared_organization_account_access_role" {
  provider           = aws.suna_shared
  name               = "OrganizationAccountAccessRole"
  assume_role_policy = data.aws_iam_policy_document.organization_account_access_principals.json
}

################################################################################
# Minimum IAM policy and IAM group for human
################################################################################
data "aws_iam_policy_document" "suna_changeable_self_iam" {
  statement {
    actions = [
      "iam:GetAccountPasswordPolicy",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.master.account_id}:*",
    ]
  }
  statement {
    actions = [
      "iam:ListUsers",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.master.account_id}:user/",
    ]
  }
  statement {
    actions = [
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.master.account_id}:mfa/",
    ]
  }
  statement {
    actions = [
      "iam:ChangePassword",
      "iam:EnableMFADevice",
      "iam:DeactivateMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:CreateAccessKey",
      "iam:UpdateAccessKey",
      "iam:DeleteAccessKey",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.master.account_id}:user/$${aws:username}",
    ]
  }
  statement {
    actions = [
      "iam:DeleteVirtualMFADevice",
      "iam:CreateVirtualMFADevice",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.master.account_id}:mfa/$${aws:username}",
    ]
  }
}
resource "aws_iam_policy" "suna_changeable_self_iam" {
  name        = "suna-changeable-self-iam"
  path        = "/"
  description = "Minimum IAM policy for human"
  policy      = data.aws_iam_policy_document.suna_changeable_self_iam.json
}
resource "aws_iam_group" "suna_all_iam_users_for_human" {
  name = "suna-all-iam-users-for-human"
  path = "/"
}
resource "aws_iam_group_policy_attachment" "attach_suna_changeable_self_iam_policy_to_suna_all_iam_users_for_human_group" {
  group      = aws_iam_group.suna_all_iam_users_for_human.name
  policy_arn = aws_iam_policy.suna_changeable_self_iam.arn
}

################################################################################
# Be able to read each account all resources
################################################################################
resource "aws_iam_group" "suna_read_only_for_master" {
  name = "suna-read-only"
  path = "/"
}
resource "aws_iam_group_policy_attachment" "attach_read_only_access_to_suna_read_only_for_master" {
  group      = aws_iam_group.suna_read_only_for_master.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
data "aws_iam_policy_document" "assume_role_policy_for_other_account_read_only_role" {
  statement {
    actions = ["sts:AssumeRole"]
    #principals {
    #  type        = "AWS"
    #  identifiers = [
    #    "arn:aws:iam::${data.aws_caller_identity.master.account_id}:user/",
    #  ]
    #}
    resources = [
      aws_iam_role.suna_read_only_for_development.arn,
      aws_iam_role.suna_read_only_for_shared.arn,
    ]
  }
}
resource "aws_iam_policy" "suna_assume_role_policy_for_other_account_read_only_role" {
  name        = "suna-assumable-role-for-other-account-read-only"
  path        = "/"
  description = "Assume role policy for other account read only role"
  policy      = data.aws_iam_policy_document.assume_role_policy_for_other_account_read_only_role.json
  depends_on = [
    aws_iam_role.suna_read_only_for_development,
    aws_iam_role.suna_read_only_for_shared,
  ]
}
resource "aws_iam_group_policy_attachment" "attach_assume_role_for_other_account_read_only_role_to_suna_read_only_for_master" {
  group      = aws_iam_group.suna_read_only_for_master.name
  policy_arn = aws_iam_policy.suna_assume_role_policy_for_other_account_read_only_role.arn
}

################################################################################
# Human IAM user suna
################################################################################
resource "aws_iam_user" "suna" {
  name = "suna"
  path = "/"
}
resource "aws_iam_user_group_membership" "suna_group_membership" {
  user = aws_iam_user.suna.name
  groups = [
    aws_iam_group.suna_all_iam_users_for_human.name,
    aws_iam_group.suna_read_only_for_master.name,
  ]
}

################################################################################
# Read only role for multiple account
################################################################################
data "aws_iam_policy_document" "read_only_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_user.suna.arn
      ]
    }
  }
}
resource "aws_iam_role" "suna_read_only_for_development" {
  provider           = aws.suna_development
  name               = "suna-read-only-development"
  assume_role_policy = data.aws_iam_policy_document.read_only_assume_role_policy.json
}
resource "aws_iam_role_policy_attachment" "attach_read_only_access_to_suna_read_only_role_for_development" {
  provider   = aws.suna_development
  role       = aws_iam_role.suna_read_only_for_development.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
resource "aws_iam_role" "suna_read_only_for_shared" {
  provider           = aws.suna_shared
  name               = "suna-read-only-shared"
  assume_role_policy = data.aws_iam_policy_document.read_only_assume_role_policy.json
}
resource "aws_iam_role_policy_attachment" "attach_read_only_access_to_suna_read_only_role_for_shared" {
  provider   = aws.suna_shared
  role       = aws_iam_role.suna_read_only_for_shared.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
