# Agent Instructions

Before starting any task in this repository:

1. Run `make agents/sync`. It writes the shared Plus3 IT instructions for this repository's tardigrade-ci version to `.agents/plus3it/AGENTS.md`.
2. Read `.agents/plus3it/AGENTS.md` and follow it together with this file. If the sync fails, tell the user, and don't guess the conventions.

These rules always apply, even without the shared instructions:

- Don't push, open pull requests, publish releases, or apply infrastructure changes unless the user asks. List those steps for a person in your final report.
- Don't edit files under `.agents/plus3it/`; they are generated and overwritten by the sync.

@.agents/plus3it/AGENTS.md

## Repository-specific

### Purpose

This Terraform module creates an AWS CloudTrail trail that delivers logs to an existing S3 bucket (`cloudtrail_bucket`). By default it also creates a KMS key to encrypt the logs, and a CloudWatch log group with an IAM role for the trail; each can be replaced with an existing one through `kms_key_id`, `cloud_watch_logs_group_name`, and `cloud_watch_logs_role_arn`. The trail's data events are set with `event_selectors` or `advanced_event_selectors`, and the module outputs `cloudtrail_id`, `cloudtrail_arn`, `cloudtrail_home_region`, `kms_key_id`, and `log_group`.

### Module-specific files

- `tests/templates/` — JSON policy templates (S3 bucket policy and KMS key policy) shared by the test scenarios
