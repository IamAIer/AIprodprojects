# One-deploy plan

## Goal

Use AWS CDK to define the first AWS deployment as one stack. A maintainer should be able to deploy or update that stack with one reviewed command, rather than creating each AWS resource by hand.

## Planned AWS components

- API Gateway endpoints for the application chat and Jira webhook.
- Lambda functions for chat requests, Jira intake/comments, SOP draft and approval handling, and read-only Kafka checks.
- Amazon Bedrock model access for the first LLM provider.
- Versioned S3 storage for approved SOPs and source files, plus the selected indexing/knowledge-base service.
- Secrets Manager entries for Jira and Kafka connection credentials.
- IAM roles, CloudWatch logs/alarms, and any required VPC networking.

The final resource list depends on the selected chat hosting, Kafka network location, Jira authentication method, and knowledge-base service.

## Before connecting company systems

The deploy must be configured with:

- AWS account, region, and the Bedrock model approved for use.
- Jira site, project, issue types, required ticket fields, and a least-privilege integration account.
- Kafka cluster endpoints, authentication method, network/VPC details, and the read-only permissions available to the assistant.
- Which company users can chat with the assistant and which maintainers can approve SOP updates.
- The destination and access rules for production-to-SDE mirroring tickets.

Use placeholders or secret references for credentials. Do not commit real tokens, passwords, broker addresses, or internal SOPs.

## Deployment and activation

1. Review the CDK diff and the IAM/network permissions.
2. Deploy the stack to a sandbox AWS account and test with non-production Jira and Kafka resources.
3. Add required secrets and approved SOP files, then run the knowledge-base sync.
4. Configure the Jira webhook URL and event filter.
5. Confirm users can only see allowed information, ticket creation uses the correct fields, and Kafka tools cannot modify cluster state.
6. Enable production access only after the service owner approves the configuration.

The deployment command can create AWS resources, but Jira webhook registration and company-side network/secret configuration may still need a one-time setup step. The project should report these clearly rather than claim that every integration is active immediately after deployment.
