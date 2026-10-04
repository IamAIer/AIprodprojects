# Deploy the first Jira bot

This Terraform stack deploys the Jira answer bot separately from the Kafka cluster. It creates a Lambda function, a signed Jira webhook endpoint, a private versioned S3 bucket for approved SOP files, a Secrets Manager secret, and the required IAM permissions. It does not create or connect to Kafka resources and does not configure Datadog.

## Before planning

You need:

- The Jira Cloud project key.
- The Bedrock model ID (or inference profile ID) and the ARN(s) the Lambda role must be allowed to invoke. Cross-Region inference can require multiple ARNs.
- A Jira bot account with permission to read issues and add comments to the chosen project.
- A high-entropy webhook secret configured in the Jira webhook. Store it and the Jira API credentials in the generated Secrets Manager secret; never put them in Terraform variables or Git.
- The approved SOP files, to upload under the S3 `approved/` prefix after deployment.

The account and region must allow the selected Bedrock model. The model is only invoked for process questions with a matching approved SOP. Health questions receive a clear message that Datadog is not connected yet.

## Plan and deploy

From this folder, copy `terraform.tfvars.example` to `terraform.tfvars`, replace the example project key and Bedrock model values, then review the full plan. The real `.tfvars` file is ignored by Git. Terraform creates AWS resources only after `terraform apply` is approved.

```powershell
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

The API Gateway endpoint is public but only accepts webhook requests with a valid Jira Cloud `X-Hub-Signature` HMAC. Jira Cloud signs the request body when a webhook secret is configured. Scope the Jira webhook to the intended project and `comment_created` events.

After deployment, put the Jira credentials and the **same** webhook secret into the generated Secrets Manager secret, register the URL from `terraform output -raw jira_webhook_url`, and upload only approved `.md` or `.txt` SOPs to the output S3 bucket under `approved/`.

## Costs and cleanup

Lambda, API Gateway, CloudWatch Logs, Secrets Manager, S3 storage, and Bedrock model calls may incur charges. This stack is separate from the Kafka stack. Run `terraform destroy` from this folder only when you want to remove the bot infrastructure; first save any SOP files that need to be retained.
