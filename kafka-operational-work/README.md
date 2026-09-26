# Kafka Operational Assistant

This project contains two separately named implementations of the same LLM assistant: the first uses AWS Bedrock, and a later version uses an open-source LLM stack. Both support application teams that use the company's Kafka clusters. The assistant connects to Jira to help teams create operational tickets and to Datadog for Kafka cluster health information. It does not connect directly to any Kafka cluster.

## Folder layout

```text
kafka-operational-work/
├── bedrock/       # First implementation: AWS Bedrock
├── open-source/   # Later implementation: open-source LLM stack
├── docs/          # Workflows and requirements shared by both
└── README.md
```

Keep Bedrock-specific code and deployment files in `bedrock/`. Keep open-source model code and its deployment files in `open-source/`. Put provider-independent requirements and workflows in `docs/`.

## What it should do

- Answer application teams' questions about company Kafka clusters, using Datadog to check cluster health.
- Create Jira tickets for Kafka topic creation, alteration, and deletion requests.
- Create Jira tickets for production-to-SDE mirroring requests.
- Create Jira tickets for cleanup-policy changes from `delete` to `compact`.
- Ask for missing request details before creating a ticket.
- Explain answers and ticket details using approved SOPs and relevant Datadog health information.
- Let authorized maintainers provide context or new/revised SOPs in chat, prepare a draft update, and publish it to the knowledge base only after approval.

The assistant creates and supports Jira requests. The existing approval and execution process makes Kafka changes; the assistant does not issue Kafka create, alter, or delete commands.

Datadog is the only source the agent uses for Kafka cluster health checks. The agent must say when Datadog data is unavailable or too old to support a reliable answer. Do not configure Kafka brokers, Kafka credentials, or direct Kafka network access for the agent.

## Project boundary

Both LLM implementations belong in this project, in their separate folders. The Bedrock implementation is built first; the open-source implementation is added later. See [architecture.md](docs/architecture.md) for the shared user and system workflows.
