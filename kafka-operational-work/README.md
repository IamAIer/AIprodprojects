# Kafka Operational Assistant

This project contains two separately named implementations of the same assistant: first AWS Bedrock, then an open-source LLM stack. The first bot answers Kafka-related questions on the Jira board using approved SOPs in S3 and health information from Datadog. It does not connect directly to Kafka.

## Folder layout

```text
kafka-operational-work/
├── bedrock/       # First implementation: AWS Bedrock
├── open-source/   # Later implementation: open-source LLM stack
├── docs/          # Workflows and requirements shared by both
└── README.md
```

Keep Bedrock-specific code and deployment files in `bedrock/`. Keep open-source model code and its deployment files in `open-source/`. Put provider-independent requirements and workflows in `docs/`.

## First version: answer on the Jira board

- Answer in English on existing Jira issues about Kafka cluster health and operational processes.
- Use approved SOPs stored in S3 and Datadog for cluster health information.
- Respond with a Jira comment. It does not create operational tickets in this first version.

The bot reads/checks information only. People or existing approved processes make Kafka changes. The bot has no direct Kafka connection.

## Later work

Later, the project may add LLM-assisted creation of Jira tickets for topic create/alter/delete, production-to-SDE mirroring, and cleanup-policy changes from `compact` to `delete`. The user must review and approve a summary before a ticket is created. The existing approval and execution process still makes Kafka changes.

## Project boundary

Both implementations belong in this project, in separate folders. The Bedrock implementation is built first; the open-source implementation is later. See [architecture.md](docs/architecture.md), [requirements.md](docs/requirements.md), and [deployment-decisions.md](docs/deployment-decisions.md).
