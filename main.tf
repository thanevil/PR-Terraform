terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:*",
          "s3:*"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "pr_service" {
  filename         = "lambda.zip"
  function_name    = "PRServiceFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      GITHUB_TOKEN = var.github_token
      REPO_NAME    = "thanevil/PR-Service"
    }
  }
}

resource "aws_api_gateway_rest_api" "pr_service_api" {
  name        = "PR Service API"
  description = "API for triggering PR Service Lambda"
}

resource "aws_api_gateway_resource" "pr_service_resource" {
  rest_api_id = aws_api_gateway_rest_api.pr_service_api.id
  parent_id   = aws_api_gateway_rest_api.pr_service_api.root_resource_id
  path_part   = "trigger"
}

resource "aws_api_gateway_method" "pr_service_method" {
  rest_api_id   = aws_api_gateway_rest_api.pr_service_api.id
  resource_id   = aws_api_gateway_resource.pr_service_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "pr_service_integration" {
  rest_api_id             = aws_api_gateway_rest_api.pr_service_api.id
  resource_id             = aws_api_gateway_resource.pr_service_resource.id
  http_method             = aws_api_gateway_method.pr_service_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.pr_service.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pr_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.pr_service_api.execution_arn}/*/*"
}

resource "aws_s3_bucket" "lambda_code" {
  bucket = "pr-service-lambda-code"
}

resource "aws_s3_bucket_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_code.bucket
  key    = "lambda.zip"
  source = "path/to/lambda.zip"
}