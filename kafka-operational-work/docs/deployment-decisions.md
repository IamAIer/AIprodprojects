# Deployment decisions and remaining setup

## Decided

- First implementation: AWS Bedrock and Lambda, in the `bedrock/` folder.
- Initial AWS Region: Asia Pacific (Mumbai), `ap-south-1`.
- First-version interface: answer on the Jira board by commenting on existing relevant issues.
- Approved SOP documents are stored in AWS S3.
- Datadog is the only source for Kafka cluster health. The bot must not connect directly to Kafka.
- English only.
- Admin1, Admin2, Admin3, and Admin4 may maintain and approve SOP updates.
- The bot only reads/checks information in the first version. Humans or existing approved processes make Kafka changes.

## Check during AWS setup

- Use AWS CLI in the selected account and `ap-south-1` to check which Bedrock models are available and enabled. Model choice is not set yet.
- No existing VPC is available. Because the bot has no direct Kafka connection, do not create Kafka broker routes or Kafka credentials. Decide later whether a VPC is needed for company network policies or service access.
- Use the company's existing Datadog account and read-only API access if available. This avoids adding a new monitoring stack; confirm with the Datadog administrator whether current API access has any additional charge.

## Pending from the Jira setup

- Jira site, project/board, issue filter, and bot account will be supplied after Jira is created in the separate Jira setup work.
- Confirm which application-team group is allowed to ask questions.
- Confirm the issue types and comment permissions for the answer bot.

## For later ticket creation

When LLM-assisted ticket creation is added, it must first show the collected request details for user approval. Ticket types include topic create/alter/delete, production-to-SDE mirroring, and cleanup-policy change from `compact` to `delete`. Required fields for each ticket type must be finalized with the Jira configuration.
