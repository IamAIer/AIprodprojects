# Assistant workflows

## User entry points

In the first version, application teams use the bot by asking or commenting on an existing Jira issue. There is no separate application chat interface in this version.

## Answer a Kafka question

1. An application-team member asks a Kafka health or process question on a Jira issue.
2. The bot searches approved SOPs in S3. For cluster health, it reads relevant information from Datadog.
3. It replies in English as a Jira comment and identifies the SOP or Datadog information used.
4. If the needed Datadog information is unavailable, incomplete, or too old, it says so instead of guessing.

Questions are limited to Kafka cluster health and operational process. The bot uses Datadog and approved SOPs; it has no direct Kafka client, broker connection, or Kafka credentials.

## Later: create a Jira operations ticket

Ticket creation is not part of the first version. When added later, a user can ask the assistant to submit a Kafka operation.

1. The assistant identifies the operation type and collects the required details. Supported request types include:
   - Create a topic.
   - Alter a topic.
   - Delete a topic.
   - Mirror data from production to SDE.
   - Change cleanup policy from `compact` to `delete`.
2. The assistant collects missing details, then shows a summary for the user to approve.
3. Only after approval does Jira create the operational ticket and return its link/key.
4. The team's normal approval and execution process performs the Kafka change. The assistant does not issue Kafka create, alter, or delete commands.

## Help with Jira tickets

The first-version bot answers on existing Kafka Jira issues, explains relevant approved SOP guidance, and uses Datadog health information when needed. It must ignore its own comments when processing Jira events to avoid a reply loop.

## Later: update approved knowledge through chat

In the first version, Admin1 through Admin4 maintain the approved SOP files in S3. A separate chat-based workflow for submitting, reviewing, and approving proposed SOP updates may be added later. Only approved, versioned material is used for application-team answers.

## Two implementations in one project

The first implementation uses AWS Bedrock and belongs in `../bedrock/`. The later implementation uses an open-source LLM stack and belongs in `../open-source/`. Keep the user workflows in this document consistent across both. Provider-specific code and deployment files stay in their named implementation folder.

## Access and audit

- Check the user's identity and permissions before answering on Jira.
- Give the first-version Jira integration permission to read relevant issues and add comments only.
- Connect to Datadog for read-only Kafka cluster health checks. Do not connect the agent directly to Kafka or give it Kafka credentials or broker network access.
- Show when Datadog data is unavailable, incomplete, or failed.
- Record who asked, which Jira issue was answered, and which approved sources or checks informed the response. For later ticket creation, record the requester and created ticket.
- Do not put credentials in source files or expose them in answers or logs.
