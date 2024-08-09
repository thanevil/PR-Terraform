provider "github" {
  token = var.pr_access_token
}

resource "github_actions_secret" "aws_access_key_id" {
  repository     = "PR-Terraform"
  secret_name    = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key_id
}

resource "github_actions_secret" "aws_secret_access_key" {
  repository     = "PR-Terraform"
  secret_name    = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_access_key
}

variable "repositories" {
  type    = list(string)
  default = ["PR-Terraform", "PR-Service"]
}

resource "github_actions_secret" "pr_access_token" {
  for_each        = toset(var.repositories)
  repository      = each.value
  secret_name     = "PR_ACCESS_TOKEN"
  plaintext_value = var.pr_access_token
}

variable "pr_access_token" {
  type = string
  description = "GitHub token to authenticate with the GitHub API."
}

variable "aws_access_key_id" {
  type = string
  description = "AWS Access Key ID."
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key."
}
#########################################
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}



resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "pr-service-bucket-cp"
}

resource "aws_iam_role" "github-oidc-role" {
  name = "github-oidc-role"
  assume_role_policy = <<EOF

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::654654242440:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:thanevil/PR-Service:*"
        }
      }
    }
  ]
}

EOF
}

resource "aws_iam_role_policy" "github-oidc-role_policy" {
  name   = "github-oidc-role_policy"
  role   = aws_iam_role.github-oidc-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::pr-service-bucket-cp/*"
    }
  ]
}
EOF
}