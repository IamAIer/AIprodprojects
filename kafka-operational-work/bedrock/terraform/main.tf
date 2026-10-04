data "archive_file" "bot" {
  type             = "zip"
  source_file      = "${path.module}/../bot/handler.py"
  output_path      = "${path.module}/bot.zip"
  output_file_mode = "0644"
}

resource "aws_s3_bucket" "sops" {
  bucket = "kafka-operational-sops-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${var.environment}"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "sops" {
  bucket                  = aws_s3_bucket.sops.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sops" {
  bucket = aws_s3_bucket.sops.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "sops" {
  bucket = aws_s3_bucket.sops.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_secretsmanager_secret" "jira" {
  name                    = "${local.name}/jira"
  description             = "Jira API credentials and signed webhook secret for the answer bot. Add the secret value outside Terraform."
  recovery_window_in_days = 7
  tags                    = local.tags
}

resource "aws_iam_role" "lambda" {
  name = "${local.name}-lambda-role"
  tags = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name = "${local.name}-access"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteFunctionLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      },
      {
        Sid      = "ReadJiraSecret"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.jira.arn
      },
      {
        Sid      = "ReadApprovedSopList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.sops.arn
        Condition = {
          StringLike = { "s3:prefix" = [var.sop_prefix, "${var.sop_prefix}*"] }
        }
      },
      {
        Sid      = "ReadApprovedSopFiles"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.sops.arn}/${var.sop_prefix}*"
      },
      {
        Sid      = "InvokeSelectedBedrockModel"
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = var.bedrock_model_arns
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_lambda_function" "bot" {
  function_name    = local.name
  description      = "Answers approved Kafka process questions on Jira issues."
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.bot.output_path
  source_code_hash = data.archive_file.bot.output_base64sha256
  memory_size      = 512
  timeout          = 30
  tags             = local.tags

  environment {
    variables = {
      JIRA_SECRET_ARN  = aws_secretsmanager_secret.jira.arn
      JIRA_PROJECT_KEY = var.jira_project_key
      TRIGGER_PHRASE   = var.trigger_phrase
      SOP_BUCKET       = aws_s3_bucket.sops.id
      SOP_PREFIX       = var.sop_prefix
      BEDROCK_MODEL_ID = var.bedrock_model_id
      JIRA_API_VERSION = "3"
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

resource "aws_apigatewayv2_api" "jira_webhook" {
  name          = "${local.name}-webhook"
  protocol_type = "HTTP"
  tags          = local.tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.jira_webhook.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.bot.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 29000
}

resource "aws_apigatewayv2_route" "jira_webhook" {
  api_id    = aws_apigatewayv2_api.jira_webhook.id
  route_key = "POST /jira/webhook"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.jira_webhook.id
  name        = "$default"
  auto_deploy = true
  tags        = local.tags
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowJiraWebhookApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.jira_webhook.execution_arn}/*/POST/jira/webhook"
}
