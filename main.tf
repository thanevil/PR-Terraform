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

resource "github_actions_secret" "pr_access_token" {
  repository     = "PR-Terraform"
  secret_name    = "PR_ACCESS_TOKEN"
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
  type = string
  description = "AWS Secret Access Key."
}