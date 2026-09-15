#!/usr/bin/env bash
# tf-drift-check.sh
# Gathers Terraform plan evidence and checks it for destructive actions
# and unsafe open-ingress rules. Read-only: never runs terraform apply,
# terraform destroy, or any command using -auto-approve.

set -uo pipefail

FULL_NAME="Aanuoluwapo Tolu-Omodara"
TF_DIR="."
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/tf-drift-report.txt"
PLAN_FILE="${REPORT_DIR}/tfplan.out"
PLAN_JSON="${REPORT_DIR}/tfplan.json"

mkdir -p "$REPORT_DIR"

declare -a CHECKS=()
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

record_check() {
  local name="$1" status="$2" detail="$3"
  CHECKS+=("${name}|${status}|${detail}")
  case "$status" in
    PASS) PASS_COUNT=$((PASS_COUNT + 1)) ;;
    WARN) WARN_COUNT=$((WARN_COUNT + 1)) ;;
    FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
  esac
}

check_terraform_plan() {
  terraform plan -detailed-exitcode -out="$PLAN_FILE" > /tmp/tf-plan-output.txt 2>&1
  local exit_code=$?

  case "$exit_code" in
    0)
      record_check "Terraform Plan Status" "PASS" "No pending changes (exit code 0)."
      ;;
    2)
      record_check "Terraform Plan Status" "WARN" "Terraform detected pending changes (exit code 2)."
      terraform show -json "$PLAN_FILE" > "$PLAN_JSON" 2>/dev/null
      ;;
    *)
      record_check "Terraform Plan Status" "FAIL" "terraform plan returned an error (exit code ${exit_code})."
      ;;
  esac

  return "$exit_code"
}

check_destructive_actions() {
  if [ ! -f "$PLAN_JSON" ]; then
    record_check "Destructive Actions Check" "PASS" "No pending plan JSON to inspect."
    return
  fi

  local found
  found=$(jq '[.resource_changes[]?.change.actions[]?] | any(. == "delete")' "$PLAN_JSON")

  if [ "$found" = "true" ]; then
    local resources
    resources=$(jq -r '.resource_changes[] | select(.change.actions[]? == "delete") | .address' "$PLAN_JSON" | paste -sd ", " -)
    record_check "Destructive Actions Check" "WARN" "Delete/replace action found on: ${resources}"
  else
    record_check "Destructive Actions Check" "PASS" "No delete or replace actions in the pending plan."
  fi
}

check_open_ingress() {
  if [ ! -f "$PLAN_JSON" ]; then
    record_check "Open Ingress Check" "PASS" "No pending plan JSON to inspect."
    return
  fi

  local aws_open
  aws_open=$(jq '[.resource_changes[]?.change.after.ingress[]? // empty
    | select(.cidr_blocks[]? == "0.0.0.0/0")] | length' "$PLAN_JSON" 2>/dev/null || echo 0)

  local azure_open
  azure_open=$(jq '[.resource_changes[]?.change.after.security_rule[]? // empty
    | select(.direction == "Inbound" and .access == "Allow"
        and (.source_address_prefix == "*" or .source_address_prefix == "0.0.0.0/0" or .source_address_prefix == "Internet"))] | length' "$PLAN_JSON" 2>/dev/null || echo 0)

  local total=$((aws_open + azure_open))

  if [ "$total" -gt 0 ]; then
    record_check "Open Ingress Check" "FAIL" "Found ${total} inbound rule(s) open to unrestricted source (0.0.0.0/0 / * / Internet)."
  else
    record_check "Open Ingress Check" "PASS" "No unrestricted inbound rules found in the pending plan."
  fi
}

write_report() {
  local overall="HEALTHY"
  local script_exit=0

  if [ "$FAIL_COUNT" -gt 0 ]; then
    overall="FAIL"
    script_exit=2
  elif [ "$WARN_COUNT" -gt 0 ]; then
    overall="WARN"
    script_exit=1
  fi

  {
    echo "Terraform Drift and Policy Review Report"
    echo "Reviewer: ${FULL_NAME}"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "----------------------------------------"
    for entry in "${CHECKS[@]}"; do
      IFS='|' read -r name status detail <<< "$entry"
      printf "[%s] %s — %s\n" "$status" "$name" "$detail"
    done
    echo "----------------------------------------"
    echo "PASS: ${PASS_COUNT}, WARN: ${WARN_COUNT}, FAIL: ${FAIL_COUNT}"
    echo "Overall Status: ${overall}"
    echo "Script Exit Code: ${script_exit}"
  } > "$REPORT_FILE"

  cat "$REPORT_FILE"
  return "$script_exit"
}

check_terraform_plan
check_destructive_actions
check_open_ingress
write_report
exit $?
