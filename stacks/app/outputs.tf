output "api_endpoint" {
  description = "Base URL of the HTTP API (e.g. https://xxxx.execute-api.us-east-1.amazonaws.com)."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "health_url" {
  description = "Full URL for the GET /health endpoint."
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/health"
}

output "lambda_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.health.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution IAM role."
  value       = aws_iam_role.lambda_exec.arn
}

output "lambda_log_group" {
  description = "CloudWatch log group for the Lambda function."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "api_access_log_group" {
  description = "CloudWatch log group for API Gateway access logs."
  value       = aws_cloudwatch_log_group.api_access.name
}
