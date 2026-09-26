# Kafka Operational Assistant

An LLM assistant for application teams that answers questions about company Kafka clusters, helps create Kafka operations tickets in Jira, and lets authorized maintainers add approved company context and SOPs to its knowledge base.

## First deployment

The first version will use AWS Bedrock for the LLM and AWS Lambda for backend tasks. AWS CDK will define the infrastructure so one deployment command can create or update the required AWS resources together.

The design will keep the LLM provider replaceable so a later version can use an open-source model stack without rebuilding the Jira, Kafka, or application workflows.

## What users can do

- Ask company Kafka questions in chat and get answers based on approved SOPs and permitted, read-only cluster checks.
- Ask the assistant to create Jira tickets for topic creation, alteration or deletion, production-to-SDE mirroring, and cleanup-policy changes from `delete` to `compact`.
- Get help with existing Jira tickets and see which SOPs or checks support the answer.
- Authorized maintainers can submit context or new/revised SOPs in chat. The assistant prepares a draft for review; only an approved version is added to the live knowledge base.

The assistant does not directly run Kafka create, alter, or delete operations. Existing human approval and execution processes remain responsible for carrying out changes.

## Deployment shape

See [architecture.md](docs/architecture.md) for the planned components and [deployment-plan.md](docs/deployment-plan.md) for the one-deploy setup and information needed before connecting to real services.

## Current status

This folder is the project scaffold and deployment plan. It does not contain AWS credentials, company SOPs, Jira secrets, or access to a Kafka network, and it has not deployed resources.
