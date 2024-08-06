output "lambda_function_arn" {
  value = aws_lambda_function.pr_service.arn
}

output "api_gateway_endpoint" {
  value = aws_api_gateway_rest_api.pr_service_api.execution_arn
}