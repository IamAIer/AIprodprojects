output "jira_webhook_url" {
  description = "HTTPS endpoint to register as the signed Jira Cloud webhook URL."
  value       = "${aws_apigatewayv2_api.jira_webhook.api_endpoint}/jira/webhook"
}

output "sop_bucket_name" {
  description = "Private, versioned S3 bucket for approved SOP files."
  value       = aws_s3_bucket.sops.id
}

output "jira_secret_arn" {
  description = "Secrets Manager secret to populate with Jira credentials and the webhook secret."
  value       = aws_secretsmanager_secret.jira.arn
}

output "lambda_name" {
  description = "Jira answer bot Lambda function name."
  value       = aws_lambda_function.bot.function_name
}
