# Architecture

## First version: AWS Bedrock

```text
Application team chat ------------------+
                                         |
Jira events / ticket requests ----------+--> API Gateway --> AWS Lambda
                                                              |
                         +------------------------------------+-------------------+
                         |                                    |                   |
                    Amazon Bedrock                    Knowledge base       Read-only Kafka
                    LLM and reasoning                   SOP/context          checks
                         |                                    |                   |
                         +--------------------+---------------+-------------------+
                                              |
                                      Jira API / comments
```

The exact AWS Knowledge Bases configuration can be chosen during implementation. Source files should be stored in versioned storage and indexed only after an authorized maintainer approves them.

## Main flows

### Ask a Kafka question

1. An authenticated application user asks in chat or Jira.
2. Lambda sends the request to Bedrock with relevant approved SOP content.
3. When useful and permitted, read-only Kafka tools check the cluster.
4. The assistant answers with the sources and checks it used. If a check is unavailable, it says so.

### Create an operations ticket

1. The user asks for a Kafka operation, such as creating a topic or mirroring production data to SDE.
2. The assistant collects required fields and confirms the request summary.
3. A Jira integration creates a ticket using the configured issue type and project.
4. The team's existing approval and execution flow handles the Kafka change. The assistant does not execute it.

### Update SOP knowledge

1. An authorized maintainer gives the assistant context or a new/revised SOP in chat.
2. The assistant prepares a proposed update and points out unclear or conflicting information.
3. A maintainer reviews and approves the draft.
4. The system stores a new version, indexes it, and confirms when it is available. Unapproved drafts are never used to answer application-team questions.

## Provider boundary

Keep model calls behind a small provider interface. The first provider uses Amazon Bedrock. A later open-source provider can implement the same interface while keeping the chat, ticket rules, SOP workflow, and Kafka read-only tools separate from model-specific code.

## Safety and access

- Authenticate chat users and enforce company access rules for cluster information.
- Give the Jira integration only the permissions needed to create and comment on approved ticket types.
- Keep Kafka tools read-only and use least-privilege network and IAM access.
- Ignore the assistant's own Jira comments to prevent repeated webhook processing.
- Keep credentials in AWS Secrets Manager; never put tokens or broker credentials in source files.
- Log request IDs and actions without logging secrets or unnecessary sensitive ticket content.
