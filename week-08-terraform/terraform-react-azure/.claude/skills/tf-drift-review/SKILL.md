---
name: tf-drift-review
description: Runs the Terraform drift and policy check script, reads the generated report, and explains the findings in plain language. Use when the user wants to review whether their Terraform-managed Azure environment matches its configuration, or wants a drift/security policy summary before considering any infrastructure change.
allowed-tools: Bash, Read, Grep
---

# Terraform Drift and Policy Review

## What this Skill does
1. Runs `AI Assignment/tf-drift-check.sh` to gather fresh evidence (Terraform plan
   exit code, plan JSON if changes are pending, destructive-action check, open-ingress
   check).
2. Reads `reports/tf-drift-report.txt` (and `reports/tfplan.json` if it exists).
3. Explains the findings in plain language, following CLAUDE.md's Review Workflow
   and Output Rules.
4. Recommends what the human should consider next — never performs the action.

## Safety rules (see CLAUDE.md for full detail)
- Never run `terraform apply`.
- Never run `terraform destroy`.
- Never run any command containing `-auto-approve`.
- Never edit `.tf`, `.tfvars`, or state files.
- If `reports/tfplan.json` is missing, check whether the report explains why
  (a clean baseline legitimately has no plan JSON) before treating it as an error.
- Distinguish findings that come from the *current* pending plan from conditions
  that already existed before this review (e.g. a pre-existing open rule that
  isn't part of what changed).

## Steps to follow every time this Skill runs
1. Run: `bash "AI Assignment/tf-drift-check.sh"`
2. Read: `reports/tf-drift-report.txt`
3. If `reports/tfplan.json` exists, read it to identify exactly which resource(s)
   changed and why.
4. Report: Terraform plan exit code and meaning, Overall Status, what changed
   (if anything) and on which resource, whether each finding is new drift or a
   pre-existing condition, and a recommendation for the human — not an action taken.
