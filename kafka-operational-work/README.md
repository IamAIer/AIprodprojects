# Kafka Operational Assistant

This project defines an LLM assistant for application teams that use the company's Kafka clusters. The assistant connects to Jira to help teams create operational tickets, and answers Kafka questions using approved company information and permitted cluster checks.

## What it should do

- Answer application teams' questions about company Kafka clusters.
- Create Jira tickets for Kafka topic creation, alteration, and deletion requests.
- Create Jira tickets for production-to-SDE mirroring requests.
- Create Jira tickets for cleanup-policy changes from `delete` to `compact`.
- Ask for missing request details before creating a ticket.
- Explain answers and ticket details using approved SOPs and relevant read-only Kafka checks.
- Let authorized maintainers provide context or new/revised SOPs in chat, prepare a draft update, and publish it to the knowledge base only after approval.

The assistant creates and supports Jira requests. The existing approval and execution process makes Kafka changes; the assistant does not issue Kafka create, alter, or delete commands.

## Project boundary

This repository covers the assistant's user-facing behavior, Jira workflows, Kafka question-answering, and knowledge-base rules. Detailed AWS deployment work (including Bedrock, Lambda, and one-click deployment) will be developed in a separate project.

See [architecture.md](docs/architecture.md) for the user and system workflows.
