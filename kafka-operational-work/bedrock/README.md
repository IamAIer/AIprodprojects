# Bedrock implementation

This folder is for the first implementation of the Kafka Operational Assistant using AWS Bedrock.

Keep Bedrock-specific application code, AWS Lambda functions, AWS infrastructure definitions, configuration examples, and deployment instructions here. Do not put real credentials, company SOPs, or private Kafka connection details in Git.

Follow the shared workflows in [../docs/architecture.md](../docs/architecture.md). The first version answers questions on existing Jira issues and only adds comments. Jira operational ticket creation is a later feature; the assistant never runs Kafka create, alter, or delete commands.

The initial Jira answer bot is in [bot/](bot/README.md). It answers process questions from approved S3 SOPs. Live Kafka health answers will be enabled after the Datadog integration is added.
