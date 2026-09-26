# Datadog health checks

The assistant connects to Datadog for Kafka cluster health. It does not connect directly to a Kafka cluster: do not configure broker endpoints, Kafka credentials, Kafka client libraries, or agent network access to Kafka. Datadog access is read-only; the assistant reads health information and does not make changes through Datadog.

## Answering with Datadog data

- Check the cluster and time period relevant to the user's question.
- State when the health information was checked and give a Datadog link or monitor reference when available.
- Do not call a cluster healthy when the needed data is missing, delayed, or unclear. Explain the gap and suggest contacting the Kafka team.
- Do not show health information for clusters the signed-in user is not allowed to see.

## Details to decide during implementation

- Which Datadog organization/site and authentication method to use.
- Which clusters, dashboards, monitors, and metrics the assistant may read.
- How recent the data must be for a health answer to count as current.
- Which Datadog groups map to the company's user access rules.

Store Datadog credentials in the selected deployment's secret store. Never commit credentials to this repository. Do not store Kafka credentials for this assistant.
