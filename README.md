# incident-simulation-platform

Least-privilege AWS infrastructure platform built with Terraform to simulate production incident scenarios and practice RBAC, STS escalation, and API troubleshooting.

---

## Overview

This project implements a remote Terraform backend and AWS infrastructure stack using strict separation of duties.

Terraform execution is performed under a least-privileged identity.  
Administrative changes require explicit STS role assumption.

The goal is to model how infrastructure is managed in real production environments.

---

## Architecture

### Execution Identities

- **terraform-bootstrap** – least-privileged Terraform execution user  
- **iam-admin** – IAM user allowed to assume AdminRole  
- **AdminRole** – elevated role for IAM modifications only  
- **root** – MFA protected, unused after bootstrap  

### Remote Backend

- S3 bucket for Terraform state  
- DynamoDB table for state locking  
- CloudTrail enabled for API auditing  

---

## Security Model

- No persistent administrative credentials  
- No root usage after initial setup  
- Managed IAM policy version lifecycle handling  
- Capability-scoped permissions (`Get*`, `Describe*`)  
- Resource-scoped access (no wildcard bucket permissions)  
- Explicit identity verification before Terraform execution  

Terraform runs are validated with:

```bash
aws sts get-caller-identity
```

---

## Lessons Learned

- AWS managed policies have a 5-version limit  
- Terraform refresh performs deep service introspection  
- AWS SDK credential resolution order affects execution context  
- Least privilege requires capability scoping, not API-by-API enumeration  
- Identity awareness prevents false-positive permission validation  

---

## Next Steps

- AssumeRole failure injection scenarios  
- API-level troubleshooting simulations  
- CI/CD role-based execution modeling  