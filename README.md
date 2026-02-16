# Production Incident Simulation Platform (AWS + Terraform)

## Overview
Implementing a least-privileged Terraform backend and AWS infrastructure stack designed to simulate production incident scenarios.

The focus of this project is:
- IAM least privilege refinement
- STS role assumption
- Policy version lifecycle management
- Terraform remote backend (S3 + DynamoDB)
- CloudTrail auditing
- Real-world troubleshooting workflows

## Architecture
- `terraform-bootstrap` (least privilege execution identity)
- `iam-admin` → assumes `AdminRole`
- `AdminRole` → elevated IAM modifications
- S3 remote state bucket
- DynamoDB state lock table
- CloudTrail logging

## Security Highlights
- No root usage after bootstrap
- Managed policy version pruning
- Scoped `Get*/Describe*` capability permissions
- Explicit STS escalation workflow
- Verified identity before every Terraform execution

## Lessons Learned
- Terraform refresh behavior per AWS service
- IAM managed policy version limit (5 versions)
- AWS credential resolution order
- Separation of duties in infra workflows
- Capability-based least privilege design

## Next Steps
- AssumeRole failure injection
- API troubleshooting lab
- REST API full-stack debugging simulation
- CI/CD role-based execution model