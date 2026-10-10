#!/bin/bash

set -u

full_name="Aanuoluwapo Tolu-Omodara"

playbook_path="$HOME/ansible-onboarding/epicbook-prod/ansible/site.yml"
inventory_path="$HOME/ansible-onboarding/epicbook-prod/ansible/inventory.ini"

# Ansible reads ansible.cfg from the current directory, so point it at the EpicBook project config
export ANSIBLE_CONFIG="$HOME/ansible-onboarding/epicbook-prod/ansible/ansible.cfg"

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
report_dir="$base_dir/reports"
report_file="$report_dir/ansible-risk-report.txt"
raw_output_file="$report_dir/ansible-check-raw.txt"

checks=(
  check_dry_run_executed
  check_unreachable_or_failed
  check_changed_tasks
  check_service_restarts
  check_firewall_changes
  check_user_and_sudo_changes
  check_removal_changes
)

pass_count=0
warning_count=0
failure_count=0
changed_tasks=()
dry_run_exit_code=0

mkdir -p "$report_dir"
: > "$report_file"

write_line() {
  echo "$1" | tee -a "$report_file"
}

mark_pass() {
  write_line "[PASS] $1"
  pass_count=$((pass_count + 1))
}

mark_warning() {
  write_line "[WARN] $1"
  warning_count=$((warning_count + 1))
}

mark_failure() {
  write_line "[FAIL] $1"
  failure_count=$((failure_count + 1))
}

print_header() {
  write_line "========================================"
  write_line "Ansible Change Risk Review"
  write_line "========================================"
  write_line "Full Name: $full_name"
  write_line "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  write_line "Playbook: $playbook_path"
  write_line "Inventory: $inventory_path"
  write_line "Mode: --check --diff dry run only"
  write_line ""
}

run_dry_run() {
  ansible-playbook "$playbook_path" -i "$inventory_path" --check --diff > "$raw_output_file" 2>&1
  dry_run_exit_code=$?
}

check_dry_run_executed() {
  if [ -s "$raw_output_file" ] && grep -q "^PLAY RECAP" "$raw_output_file"
  then
    mark_pass "Dry run executed and produced a PLAY RECAP"
  else
    mark_failure "Dry run did not complete or produced no PLAY RECAP"
  fi
}

check_unreachable_or_failed() {
  local recap_line
  local unreachable
  local failed

  recap_line=$(grep -E "unreachable=[0-9]+.*failed=[0-9]+" "$raw_output_file" | tail -n 1)

  if [ -z "$recap_line" ]
  then
    mark_warning "Could not parse unreachable and failed counts from recap"
    return
  fi

  unreachable=$(echo "$recap_line" | sed -E "s/.*unreachable=([0-9]+).*/\1/")
  failed=$(echo "$recap_line" | sed -E "s/.*failed=([0-9]+).*/\1/")

  if [ "$unreachable" -gt 0 ] || [ "$failed" -gt 0 ]
  then
    mark_failure "Recap shows unreachable=$unreachable failed=$failed"
  else
    mark_pass "Recap shows unreachable=0 failed=0"
  fi
}

extract_changed_tasks() {
  local raw_changed_lines
  local task_line
  local task_name

  raw_changed_lines=$(awk '
    /^TASK \[/ { task_line = $0; printed = 0; next }
    /^changed: \[/ && !printed { print task_line; printed = 1 }
  ' "$raw_output_file")

  changed_tasks=()

  while IFS= read -r task_line
  do
    [ -z "$task_line" ] && continue
    task_name=$(echo "$task_line" | sed -E "s/^TASK \[(.*)\][ ]*\*+$/\1/")
    changed_tasks+=("$task_name")
  done <<< "$raw_changed_lines"
}

check_changed_tasks() {
  local changed_count="${#changed_tasks[@]}"

  if [ "$changed_count" -eq 0 ]
  then
    mark_pass "No changed tasks detected"
  else
    mark_warning "$changed_count changed task(s) detected - review before applying"
    for task_name in "${changed_tasks[@]}"
    do
      write_line "  - would change: $task_name"
    done
  fi
}

check_tasks_matching_pattern() {
  local pattern="$1"
  local label="$2"
  local matches=()
  local task_name

  for task_name in "${changed_tasks[@]}"
  do
    if echo "$task_name" | grep -qiE "$pattern"
    then
      matches+=("$task_name")
    fi
  done

  if [ "${#matches[@]}" -eq 0 ]
  then
    mark_pass "No $label tasks among the changes"
  else
    mark_failure "${#matches[@]} $label task(s) found in the changed set"
    for task_name in "${matches[@]}"
    do
      write_line "  - risky ($label): $task_name"
    done
  fi
}

check_service_restarts() {
  check_tasks_matching_pattern "restart|reload|handler|service" "service-restart"
}

check_firewall_changes() {
  check_tasks_matching_pattern "firewall|ufw|iptables|nftables|security group" "firewall"
}

check_user_and_sudo_changes() {
  check_tasks_matching_pattern "user|group|sudoer|sudo|passwd|password" "user/sudo"
}

check_removal_changes() {
  check_tasks_matching_pattern "remove|absent|delete|uninstall|purge" "removal"
}

print_summary() {
  local overall_status
  local script_exit_code

  if [ "$failure_count" -gt 0 ]
  then
    overall_status="FAIL - risky changes present, do not apply without review"
    script_exit_code=2
  elif [ "$warning_count" -gt 0 ]
  then
    overall_status="WARN - changes present, review recommended"
    script_exit_code=1
  else
    overall_status="HEALTHY - no changes detected"
    script_exit_code=0
  fi

  write_line ""
  write_line "Summary:"
  write_line "PASS: $pass_count"
  write_line "WARN: $warning_count"
  write_line "FAIL: $failure_count"
  write_line "Overall Status: $overall_status"
  write_line "Script Exit Code: $script_exit_code"
  write_line "Report File: $report_file"
  write_line "Raw Ansible Output: $raw_output_file"

  return "$script_exit_code"
}

print_header
run_dry_run
extract_changed_tasks

for check_function in "${checks[@]}"
do
  "$check_function"
done

print_summary
exit $?
