# Datadog health checks

The assistant uses Datadog as its source for Kafka cluster health. Datadog access is read-only: the assistant reads health information and does not make changes through Datadog or directly on Kafka.

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

Store Datadog credentials in the selected deployment's secret store. Never commit credentials to this repository.
