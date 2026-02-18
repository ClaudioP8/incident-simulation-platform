# incident-simulation-platform

Least-privilege AWS infrastructure platform built with Terraform to simulate production incident scenarios and practice IAM/STS, RBAC-style separation of duties, and API troubleshooting.

---

## Overview

This repo models a production-style Terraform execution pattern:

- **Control plane** (IAM changes) is isolated behind an admin role.
- **Execution plane** (Terraform runs) uses a least-privileged identity.
- **Provisioning** happens via **STS AssumeRole** into a scoped deploy role.
- **Auditability** is provided via CloudTrail for API/event inspection.

The project is intentionally designed to support controlled failure-injection and runbook-style debugging.

---

## Architecture

### Identity & Roles

**Execution identity**
- `terraform-runner` — primary Terraform execution user (active)

**Legacy / retired**
- `terraform-bootstrap` — original bootstrap execution user (kept for historical context; access keys should be removed/disabled)

**Control plane**
- `iam-admin` — IAM user allowed to assume AdminRole
- `AdminRole` — elevated role used only for IAM/trust-policy changes (break-glass / control plane)

**Provisioning role**
- `TerraformDeployRole` — role assumed by Terraform (via provider `assume_role`) to create/manage infrastructure with scoped permissions

> Key separation: IAM/trust updates require `AdminRole`. Terraform runs do not.

---

## Terraform Execution Flow

Terraform involves **two auth contexts**:

1) **Backend auth (state + locks)**  
   Executed directly as the base identity (`terraform-runner`) for:
   - S3 remote state bucket access
   - DynamoDB state lock table access

2) **Provider auth (resource provisioning)**  
   The AWS provider uses STS to assume `TerraformDeployRole`:
   - `terraform-runner` → `sts:AssumeRole` → `TerraformDeployRole`
   - All infrastructure API calls then run under the assumed role session

Validate identity before running Terraform:

```bash
aws sts get-caller-identity
```

---

## Remote Backend & Audit

- S3 bucket for Terraform state
- DynamoDB table for state locking
- CloudTrail enabled for API auditing and troubleshooting

---

## Least-Privilege Hardening Notes

`TerraformDeployRole` was hardened by removing `AdministratorAccess` and replacing it with scoped permissions.

As part of service-layer expansion (DynamoDB), permissions were refined based on real AWS API errors observed during `terraform apply`, including Terraform’s automatic introspection calls (e.g., `DescribeContinuousBackups`, `DescribeTimeToLive`).

This mirrors real-world IAM boundary tuning:
- start capability-scoped
- scope to resources (no wildcard buckets)
- refine based on observed API calls
- re-test under the non-admin execution identity

---

## Lessons Learned

- Terraform backend authentication is separate from provider `assume_role`
- Terraform refresh/apply performs deeper service introspection than expected
- Least privilege works best with capability scoping (`Get*`, `Describe*`, lifecycle actions) + resource scoping
- Managed IAM policies have a 5-version limit; policy version lifecycle matters
- Always verify execution identity to avoid false-positive “it works” tests while elevated

---

## Next Steps

- Failure-injection scenarios (AssumeRole/trust-policy failures, backend lock issues)
- API-layer lab (API Gateway + Lambda) for REST troubleshooting reps
- Runbooks folder with repeatable incident simulations (symptom → evidence → fix → prevention)
- Optional: CI/CD with GitHub OIDC (AssumeRoleWithWebIdentity) to replace long-lived keys