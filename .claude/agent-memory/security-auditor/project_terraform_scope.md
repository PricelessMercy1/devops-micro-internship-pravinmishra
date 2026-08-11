---
name: project-terraform-scope
description: This repo's terraform/ only provisions S3+CloudFront for a static portfolio site; no IAM/OIDC resources exist here
metadata:
  type: project
---

As of 2026-07-10 (re-confirmed 2026-07-13), `terraform/` (main.tf, variables.tf, outputs.tf, providers.tf, backend.tf)
provisions only: aws_s3_bucket (website), aws_s3_bucket_public_access_block,
aws_cloudfront_origin_access_control, aws_s3_bucket_policy, aws_cloudfront_distribution.
There are no aws_iam_role / aws_iam_policy / OIDC provider resources anywhere in the repo,
and there is no `.github/workflows/` directory (deleted per commit "Deleted claude related files").

**Why:** The standard security checklist includes IAM least-privilege and OIDC trust-policy
scoping checks, but those don't apply here because the resources don't exist yet — flagging
them as findings would be noise, not signal.

**How to apply:** Before flagging IAM/OIDC checklist items in this repo, confirm with
`Glob **/*.tf` and `Glob .github/workflows/*` whether those resources/workflows have been
added back. If a GitHub Actions workflow with OIDC federation is introduced later, that's
when the OIDC-scoping and IAM least-privilege checks in [[project_terraform_known_gaps]] become
relevant.
