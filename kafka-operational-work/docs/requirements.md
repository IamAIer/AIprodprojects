# Project requirements

## Goal

The first version is a bot that answers Kafka health and process questions on existing Jira issues. It uses approved SOPs stored in S3 and Datadog health information. It replies in English as a Jira comment.

This project will contain two implementations: AWS Bedrock first, then an open-source LLM stack. Both follow the same user workflows and requirements.

## First-version features

- Answer application-team questions directly on the Jira board, limited to Kafka cluster health and operational process.
- Use approved SOPs in AWS S3 for processes and Datadog for cluster health.
- Comment in English on existing relevant Jira issues. Do not create tickets in the first version.
- Say when the Datadog information is missing, incomplete, or too old; do not guess.

## Later ticket-creation feature

Ticket creation is not part of the first version. When it is added later, request types will include topic create, alter, and delete; production-to-SDE mirroring; and cleanup-policy change from `compact` to `delete`. The bot must collect required details and show a summary for user approval before creating a Jira ticket. Existing human or approved tooling processes perform Kafka changes.

## System boundaries

- The assistant connects to Jira and Datadog. It does not connect directly to Kafka.
- Do not give the assistant Kafka broker addresses, Kafka credentials, Kafka client libraries, or network access to Kafka clusters.
- Datadog access is read-only and used for cluster health information. If the needed health data is unavailable, incomplete, or too old, the assistant says so rather than guessing.
- Operational Jira ticket creation is a later feature. When it is added, people or existing approved tooling still carry out Kafka changes; the assistant does not run Kafka create, alter, or delete commands.
- Do not let the assistant change anything through Datadog.

## SOP maintenance

In the first version, Admin1 through Admin4 maintain approved SOPs in S3. A separate chat-based SOP submission and approval flow is a later feature. When built, it must keep unapproved content out of answers, preserve versions and sources, record submitter and approver, and support restoring an earlier version.

## Access and audit

- Require authentication and follow company permissions for Jira issues and Datadog information.
- In the first version, limit Jira permissions to reading relevant issues and posting comments.
- Ignore the assistant's own Jira comments when processing Jira events so it does not respond to itself repeatedly.
- Record who asked, which Jira issue was answered, and which SOPs or Datadog data supported the answer.
- Keep credentials in the selected deployment's secret store. Never put credentials or private company SOPs in source control.

## Team, language, and content

- Application teams will use the bot on Jira; the exact Jira user group is still to be named.
- Admin1, Admin2, Admin3, and Admin4 are the approved team members for SOP maintenance and approval.
- Store SOPs in AWS S3.
- The bot's answers and Jira comments are in English only.
