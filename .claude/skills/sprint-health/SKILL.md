---
name: sprint-health
description: Reads the current active sprint via Jira MCP and produces a read-only triage report — velocity so far, at-risk stories, and items missing estimates. Never creates, edits, comments on, or transitions a Jira issue.
allowed-tools: mcp__jira__jira_search, mcp__jira__jira_get_issue, mcp__jira__jira_get_sprint, mcp__jira__jira_get_board, Read
disable-model-invocation: true
---
 
# Sprint Health Skill
 
When `/sprint-health` is invoked:
 
1. Use the Jira MCP read tools to find the current active sprint on the project's Scrum board.
2. Retrieve every issue in that sprint: status, assignee, story points, and last-updated timestamp.
3. Calculate:
   - Sprint velocity so far: story points in "Done" versus total points committed
   - Days remaining in the sprint
   - Stories at risk: still "To Do" or "In Progress" with few days remaining, or with no update in several days
   - Items with no story point estimate, or with no acceptance criteria in the description
4. Report in this order:
   - Sprint name and days remaining
   - Velocity so far (points done / points committed)
   - At-risk stories, with the exact evidence (status, last update, points) for each
   - Items missing an estimate or acceptance criteria
   - One suggested talking point for standup — phrased as a question for the human Scrum Master to raise, not an instruction to act
5. Do not call any Jira MCP tool that creates, edits, comments on, or transitions an issue.
6. Do not use `Write`.
7. Never take an action on the board. Only report. The Scrum Master decides and acts manually.