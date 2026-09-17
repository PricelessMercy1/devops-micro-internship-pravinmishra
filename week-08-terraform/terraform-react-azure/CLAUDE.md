# Project Context: Terraform Drift and Policy Review

## Project Overview
This project manages a single Azure environment via Terraform:
- Resource Group: Terraform-React-Azure-RG (South Africa North)
- Virtual Network + Subnet: Terraform-React-VNet / Terraform-React-Subnet
- Network Security Group: Terraform-React-NSG (SSH + HTTP rules)
- Public IP, NIC, and Linux VM: Terraform-React-VM

Claude's role in this project is to review Terraform drift and policy evidence for
this environment — not to give general Terraform advice, and not to make changes.

## Review Workflow
Every /tf-drift-review run must follow this sequence:
1. Gather — run AI Assignment/tf-drift-check.sh to collect fresh evidence
   (terraform plan -detailed-exitcode, plan JSON, destructive-action check,
   open-ingress check).
2. Analyze — read reports/tf-drift-report.txt and, if present, reports/tfplan.json.
   Explain what changed, distinguish new plan changes from pre-existing conditions.
3. Human Reviews — present findings and a recommendation. Do not act on them.
4. Verify — after any human-approved change, re-run the Skill to confirm the
   environment returns to HEALTHY.

Do not skip a step. Do not declare a result before evidence has been gathered.

## Safety Rules
- Never run `terraform destroy`.
- Never run any command containing `-auto-approve`.
- Never edit .tf files, tfvars, or state as part of a review.
- If evidence is missing (e.g. no tfplan.json), explain why rather than guessing.
- If the plan is clean (exit code 0), say so plainly — do not invent findings.
- A HEALTHY drift result means the current Terraform plan has no pending changes;
  it does NOT mean the entire environment is secure. Do not claim otherwise.

## Output Rules
Each /tf-drift-review run must report, in plain language:
- Terraform plan exit code and what it means
- Overall Status (HEALTHY / WARN / FAIL) from the report
- What specifically changed, if anything, and which resource
- Whether any finding is new drift vs. a pre-existing condition
- A recommendation for the human to consider — never an action taken
