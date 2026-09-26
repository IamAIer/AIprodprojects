# Assistant workflows

## User entry points

Application teams can use the assistant through its chat interface or through Jira. The assistant should use the same request rules and approved company knowledge in both places.

## Answer a Kafka question

1. An application-team member asks about a company Kafka cluster.
2. The assistant checks approved SOPs and, when the question is about cluster health, reads the relevant health information from Datadog.
3. It answers in plain language, states when the Datadog data was checked, and points to the sources or checks that support the answer.
4. If Datadog data is unavailable, incomplete, or too old, it says so and asks the user or Kafka team for help instead of guessing.

Questions can include cluster usage, topic configuration, operational procedures, and troubleshooting. The assistant must only reveal information the signed-in user is allowed to see.

## Create a Jira operations ticket

1. A user asks the assistant to submit a Kafka operation.
2. The assistant identifies the operation type and collects the required details. Supported request types include:
   - Create a topic.
   - Alter a topic.
   - Delete a topic.
   - Mirror data from production to SDE.
   - Change cleanup policy from `delete` to `compact`.
3. The assistant shows a short summary and asks for missing details or confirmation when needed.
4. The Jira integration creates the appropriate operational ticket and returns its link/key to the user.
5. The team's normal approval and execution process performs the Kafka change. The assistant does not issue Kafka create, alter, or delete commands.

## Help with Jira tickets

The assistant can explain an existing Kafka ticket, identify missing information, and comment with relevant SOP guidance or read-only checks. It must ignore its own comments when processing Jira events to avoid a reply loop.

## Update approved knowledge

Authorized maintainers can provide new context or an SOP in chat. The assistant prepares a proposed knowledge-base update, highlights unclear or conflicting material, and waits for maintainer approval. Only an approved, versioned update is used for application-team answers.

## Two implementations in one project

The first implementation uses AWS Bedrock and belongs in `../bedrock/`. The later implementation uses an open-source LLM stack and belongs in `../open-source/`. Keep the user workflows in this document consistent across both. Provider-specific code and deployment files stay in their named implementation folder.

## Access and audit

- Check the user's identity and permissions before answering or creating a Jira ticket.
- Give the Jira integration only the permissions needed to create and comment on the relevant operational tickets.
- Use Datadog for read-only Kafka cluster health checks. Show when a check is unavailable, incomplete, or failed.
- Record who requested a ticket, what was created, and which approved sources or checks informed the response.
- Do not put credentials in source files or expose them in answers or logs.
