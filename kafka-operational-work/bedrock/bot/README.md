# Jira answer bot (first build step)

This is the first Bedrock bot code. Jira sends a webhook when a comment is added. A comment that contains the configured trigger phrase is answered on the same Jira issue.

## What this first version does

- Reads approved `.md` and `.txt` SOPs from the configured S3 `approved/` folder.
- Uses Amazon Bedrock to draft an English answer from matching SOP excerpts.
- Posts the answer as a Jira comment and names its SOP sources.
- Ignores the bot's own comments and comments outside the configured Jira project.
- Says live Kafka health checks are not connected yet. Datadog is a later build step.
- Does not create Jira tickets, change Kafka, or connect to Kafka brokers.

## Before deployment

The Jira site and project, trigger phrase, Bedrock model, SOP bucket, Jira API access, and webhook token are not set yet. Do not add real credentials or company SOPs to Git. Store Jira credentials and the webhook token together in AWS Secrets Manager as JSON with these keys:

```json
{
  "webhook_token": "same secret configured on the Jira webhook",
  "base_url": "https://your-company.atlassian.net",
  "email": "bot-account@example.com",
  "api_token": "replace outside Git",
  "bot_account_id": "Jira account ID of the bot"
}
```

Set these Lambda environment values during deployment:

- `JIRA_SECRET_ARN`: ARN of the secret above.
- `JIRA_PROJECT_KEY`: only answer comments from this project.
- `TRIGGER_PHRASE`: phrase a user must include to invoke the bot, such as `/kafka`.
- `SOP_BUCKET`: S3 bucket containing approved procedures.
- `SOP_PREFIX`: approved folder path; defaults to `approved/`.
- `BEDROCK_MODEL_ID`: model enabled in the chosen AWS account and region.
- `JIRA_API_VERSION`: defaults to `3` for Jira Cloud.

Configure a Jira Cloud webhook with a secret, for `comment_created` events, scoped to the configured project. Jira signs the raw webhook body in the `X-Hub-Signature` header; the Lambda validates that signature with the webhook secret stored in Secrets Manager. The Lambda must have read access only to the approved SOP prefix, read access to the Jira secret, and Bedrock model invocation access. Give the Jira bot account only the project access needed to read issues and add comments.

## Current limitation

SOP selection in this first build uses simple word matching over a small set of text files. It is a starter retrieval method, not a full search index. The bot must be pointed only at approved content. Live health answers stay disabled until the Datadog step is implemented.
