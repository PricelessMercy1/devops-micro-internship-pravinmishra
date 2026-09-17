#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../reports/hook-debug.log"

echo "--- Hook fired at $(date) ---" > "$LOG_FILE"

raw=$(cat)
echo "RAW STDIN: $raw" >> "$LOG_FILE"

cmd=$(echo "$raw" | jq -r ".tool_input.command" 2>>"$LOG_FILE")
echo "PARSED CMD: $cmd" >> "$LOG_FILE"
echo "CLAUDE_PROJECT_DIR: $CLAUDE_PROJECT_DIR" >> "$LOG_FILE"

report="${CLAUDE_PROJECT_DIR}/reports/tf-drift-report.txt"
echo "REPORT PATH: $report" >> "$LOG_FILE"

if [ -f "$report" ]; then
  echo "REPORT FILE EXISTS: yes" >> "$LOG_FILE"
  grep "Overall Status" "$report" >> "$LOG_FILE"
else
  echo "REPORT FILE EXISTS: no" >> "$LOG_FILE"
fi

if echo "$cmd" | grep -q "terraform apply"; then
  if [ -f "$report" ] && grep -q "Overall Status: FAIL" "$report"; then
    echo "DECISION: BLOCKING" >> "$LOG_FILE"
    echo "BLOCKED: The latest Terraform drift review reported Overall Status: FAIL. Review and resolve reports/tf-drift-report.txt before running terraform apply." >&2
    exit 2
  fi
fi

echo "DECISION: ALLOWING" >> "$LOG_FILE"
exit 0
