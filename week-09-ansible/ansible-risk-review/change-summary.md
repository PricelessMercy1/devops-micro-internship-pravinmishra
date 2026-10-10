# Ansible Change Summary

**Full Name:** Aanuoluwapo Tolu-Omodara

**Date:** 10/10/2026

## 1. Change Requested

I added one task to the common role (`roles/common/tasks/main.yml`): "Remove temporary EpicBook risk test file", which sets `/tmp/epicbook-risk-test` to `state: absent`. I created that file on the VM first. The purpose was to introduce a controlled, low-impact removal in my own lab, so I could confirm that the risk-review workflow catches a removal before it is applied.

## 2. Evidence Collected

The Bash report flagged the task under the removal category:

- `[FAIL] 1 removal task(s) found in the changed set`
- `risky (removal): common : Remove temporary EpicBook risk test file`
- `Overall Status: FAIL - risky changes present, do not apply without review`, exit code 2

The same report showed `[PASS] Recap shows unreachable=0 failed=0`, so the dry run completed and the FAIL was the script's risk verdict, not an Ansible error. The report was saved as `reports/risky-change-report.txt`.

## 3. Real-World Impact if Applied Blindly

In this lab the target is a harmless temporary file. The same task pattern could delete a configuration or data file that something depends on, with no way to undo it. The run also showed a second risk: the dry run predicted two changes, but the real run changed four. Two PM2 tasks that were skipped in check mode ("Remove the existing PM2 process" and "Start EpicBook with PM2") ran for real and restarted the application. Applying without review would have meant an unexpected restart of a live service.

## 4. Human-Approved Action

After reading the risky-change report, I decided the change was acceptable and ran the real playbook myself, from `~/ansible-onboarding/epicbook-prod/ansible`:

`ansible-playbook -i inventory.ini site.yml`

## 5. Verification

- The real run finished with `ok=23 changed=4 unreachable=0 failed=0 skipped=1`.
- `ansible web -i inventory.ini -m ping` returned `pong`.
- The `stat` module on `/tmp/epicbook-risk-test` returned `"exists": false`, which proves the removal happened.
- `curl` against the VM's public IP returned HTTP 200, so the app is serving after the PM2 restart.
- The post-apply review (`/ansible-risk-review`) reported HEALTHY with no changed tasks and no risky flags, saved as `reports/post-apply-report.txt`.

## 6. Safety Decision

Claude Code was allowed to gather and analyze evidence because those steps only read: it ran the review script (which uses `--check --diff`), read the two report files and explained them. It was not allowed to run the playbook for real because a real run changes a live server and cannot be undone by a dry run. The skill only allows Bash, Read and Grep, and `CLAUDE.md` forbids applying, fixing or editing, so the decision and the accountability stay with me. The dry run also proved it can be incomplete, since it missed the PM2 restart.

## 7. Agentic Loop Mapping

- **Gather:** the Bash script ran `ansible-playbook --check --diff` and produced the risk report, flagging the removal task.
- **Analyze:** Claude Code read the report through the `/ansible-risk-review` skill and explained the status, the flagged task, the likely impact and the need for review. It also pointed out that the skipped tasks had not been assessed.
- **Human Act:** I reviewed the evidence and ran the real `ansible-playbook` command myself.
- **Verify:** I checked ping, the file state and the app with `curl`, then re-ran the review, which came back HEALTHY.
