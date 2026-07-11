##############################################################################
# Lambda function
##############################################################################

locals {
  name_prefix = "${var.project}-${var.environment}"
  lambda_src  = "${path.module}/../../lambda"
}

# Package the Lambda source into a zip archive
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${local.lambda_src}/src"
  output_path = "${path.module}/../../lambda/dist/function.zip"
}

# CloudWatch log group (pre-create for retention policy)
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_prefix}-health"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "health" {
  function_name = "${local.name_prefix}-health"
  description   = "Health check handler for ${var.project} (${var.environment})"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  architectures    = ["arm64"]

  role        = aws_iam_role.lambda_exec.arn
  timeout     = var.lambda_timeout_sec
  memory_size = var.lambda_memory_mb

  # Explicitly reference the log group so Terraform manages creation order
  logging_config {
    log_group             = aws_cloudwatch_log_group.lambda.name
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  environment {
    variables = {
      NODE_ENV  = var.environment
      LOG_LEVEL = "info"
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# Allow API Gateway to invoke the Lambda — scoped to this API's execution ARN
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health.function_name
  principal     = "apigateway.amazonaws.com"

  # Narrow to exactly this API's execution ARN so no other API can invoke
  source_arn = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
