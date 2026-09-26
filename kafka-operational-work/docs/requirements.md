# Project requirements

## Goal

Provide an LLM assistant that application teams can use through chat and Jira. It answers questions about company Kafka clusters using approved company documents and Datadog health information, and creates Jira tickets for Kafka operations.

This project will contain two implementations: AWS Bedrock first, then an open-source LLM stack. Both follow the same user workflows and requirements.

## User features

- Answer application-team questions about company Kafka clusters and their operations.
- Use approved SOPs for documented processes and Datadog for cluster health checks.
- Create Jira operational tickets for topic creation, alteration, and deletion; production-to-SDE mirroring; and cleanup-policy changes from `delete` to `compact`.
- Ask for missing request details before creating a ticket, then return the Jira ticket key and link.
- Help users understand relevant Jira tickets and the approved information behind an answer.
- Provide authorized maintainers a chat to submit context or new/revised SOPs for knowledge-base updates.

## System boundaries

- The assistant connects to Jira and Datadog. It does not connect directly to Kafka.
- Do not give the assistant Kafka broker addresses, Kafka credentials, Kafka client libraries, or network access to Kafka clusters.
- Datadog access is read-only and used for cluster health information. If the needed health data is unavailable, incomplete, or too old, the assistant says so rather than guessing.
- The assistant creates operational Jira tickets; people or existing approved tooling carry out Kafka changes. The assistant does not run Kafka create, alter, or delete commands.
- Do not let the assistant change anything through Datadog.

## Knowledge-base updates

1. An authorized maintainer submits context or an SOP and says whether it is new or updates existing material.
2. The assistant drafts the proposed update and identifies unclear, unsupported, or conflicting information.
3. An authorized person reviews and approves the draft. Unapproved content is not used in answers.
4. After approval, store a new version, update the search index, and tell the maintainer when the new content is ready.
5. Keep the source, proposed changes, submitter, approver, timestamps, and published version in an audit trail. Allow restoration of a previous version.

## Access and audit

- Require authentication and follow company permissions for chat, Jira tickets, and Datadog information.
- Limit Jira permissions to the required ticket creation and comment actions.
- Ignore the assistant's own Jira comments when processing Jira events so it does not respond to itself repeatedly.
- Record who asked, what ticket was created or updated, and which SOPs or Datadog data supported the answer.
- Keep credentials in the selected deployment's secret store. Never put credentials or private company SOPs in source control.
