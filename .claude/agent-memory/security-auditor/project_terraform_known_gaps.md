---
name: project-terraform-known-gaps
description: Recurring/known security gaps found in terraform/ as of the 2026-07-13 audit, useful to diff against in future reviews
metadata:
  type: project
---

Audit on 2026-07-10 (re-confirmed 2026-07-13, no drift) of `terraform/main.tf` found the
S3+CloudFront setup already does the "hard" parts correctly: S3 public access block fully
enabled, CloudFront uses OAC (not legacy OAI) with a properly scoped bucket policy
(`aws:SourceArn` condition), and `viewer_protocol_policy = "redirect-to-https"` is set. No
hardcoded credentials/ARNs/account IDs found — everything uses variables.

Outstanding gaps as of 2026-07-13 (none were CRITICAL; no wildcard IAM since no IAM resources
exist — see [[project_terraform_scope]]):
- No `aws_s3_bucket_server_side_encryption_configuration` declared explicitly (AWS defaults to
  SSE-S3 automatically for new buckets since Jan 2023, so risk is lower than it looks, but
  explicit config is still best practice and needed if KMS is desired).
- No `aws_s3_bucket_versioning`.
- No S3 access logging (`aws_s3_bucket_logging`) and no CloudFront `logging_config` block —
  no logging bucket exists at all.
- No `aws_cloudfront_response_headers_policy` — CSP, X-Frame-Options, HSTS, X-Content-Type-Options
  all absent from the CloudFront distribution. This is the highest-value fix given the checklist
  explicitly calls out security headers.
- `.gitignore` was added at repo root (2026-07-13, not present on 2026-07-10) but it only
  ignores `.claude/settings*.json` and `terraform/.terraform/`. It does NOT ignore
  `*.tfstate`, `*.tfstate.backup`, `*.tfvars`, `crash.log`, or `override.tf` — still a real
  risk of committing local state (which would contain resource ARNs/account ID in plaintext)
  since backend.tf's S3 remote backend is commented out by default and local state is the
  default until someone completes the migration steps documented in backend.tf.
- `variable "domain_name"` is declared but unused in main.tf — no ACM cert / alias / custom
  domain wired up, so `viewer_certificate` only sets `cloudfront_default_certificate = true`.
  Not itself a vulnerability, but if a custom domain is added later, must also set
  `minimum_protocol_version = "TLSv1.2_2021"` and an ACM cert (default cert can't enforce a
  modern min TLS version).
- No WAF attached to the CloudFront distribution (optional/LOW for a static portfolio site).

**Why:** Recorded so future audits can quickly tell what's already been fixed vs. what's a
persistent known gap, rather than re-deriving the whole list from scratch each time.

**How to apply:** On the next audit, re-check each bullet against the current file contents
(don't assume it's still true) and update this memory — cross off fixed items, add newly
introduced ones.
