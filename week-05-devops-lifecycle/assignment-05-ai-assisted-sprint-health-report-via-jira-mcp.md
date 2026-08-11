# Assignment 5 — AI-Assisted Sprint Health Report via Jira MCP

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will connect Claude Code to your Jira board through an MCP server, the same way you connected it to GitHub in Week 2, and build a read-only `/sprint-health` skill. The skill reads your current sprint through Jira's API and reports sprint velocity, stories at risk of missing the sprint, and items missing an estimate — but it must never create, edit, comment on, or transition a single ticket itself. You will prove that boundary holds by making a real change on the board yourself and confirming the skill only ever reports, never acts.

---

# Task 1 — Create a Jira API Token

## Goal

Generate an API token from your Atlassian account that the MCP server will use to authenticate with your Jira site. Do not screenshot the token value itself.

### Evidence

#### Screenshot 1 — Jira API token creation confirmation page showing the token name, with the token value not visible

![Week 05 Screenshots](screenshots/week-05-screenshots-50.png)

### Notes You Must Write (Very Important):

Why does the MCP server need your site URL and account email in addition to the token?

The MCP server needs the Jira site URL and account email in addition to the API token because Jira uses the email and API token together to authenticate the account. The email identifies the specific Atlassian account, while the site URL identifies the specific Jira instance the MCP server should connect to. The API token proves that the request is authorized. Therefore, the three together tell the MCP server which Jira account to access, which Jira site to connect to, and that the request is authenticated.

---

# Task 2 — Create .mcp.json at the Project Root

## Goal

Create or update `.mcp.json` at your project root with a Jira MCP server block, following the same shape as the GitHub MCP server you configured in Week 2.

### Evidence

#### Screenshot 2 — `.mcp.json` open in VS Code showing the Jira server configuration

![Week 05 Screenshots](screenshots/week-05-screenshots-51.png)

### Notes You Must Write (Very Important):

Compare this jira block to the github block from Week 2 Assignment 5. The GitHub server ran via npx (a Node.js package); this one runs via uvx (a Python package) — what stays exactly the same shape despite that difference, and why doesn't Claude Code care which language a given MCP server is written in?

The Jira block and the GitHub block keep the same overall MCP server structure: both are defined under mcpServers and contain a command, args, and env section. The main difference is the command used to launch them: GitHub uses npx for a Node.js package, while Jira uses uvx for a Python package. Claude Code does not care which programming language the MCP server is written in because it communicates with both through the standard Model Context Protocol (MCP). It only needs to know how to start the server and communicate with it through the MCP interface.

---

# Task 3 — Add Your Credentials to settings.local.json

## Goal

Add your Jira site URL, account email, and API token to `.claude/settings.local.json`, and confirm that file is listed in `.gitignore` so it is never committed.

### Evidence

#### Screenshot 3 — `settings.local.json` open in VS Code showing the `env` section, with the actual token value blurred or covered

![Week 05 Screenshots](screenshots/week-05-screenshots-52.png)

### Notes You Must Write (Very Important):

Why must JIRA_API_TOKEN live in settings.local.json and never in .mcp.json?

JIRA_API_TOKEN must live in settings.local.json because it is a secret credential used to authenticate requests to Jira. Keeping it in the local settings file prevents the token from being exposed in the shared .mcp.json configuration. Since settings.local.json is listed in .gitignore, the token will not be committed to the Git repository.

---

# Task 4 — Verify the Connection with /mcp

## Goal

Restart Claude Code and confirm the Jira MCP server shows as connected.

### Evidence

#### Screenshot 4 — `/mcp` output showing `jira: connected`

![Week 05 Screenshots](screenshots/week-05-screenshots-53.png)

---

# Task 5 — Run a Live Query to Prove Real Board Data

## Goal

Ask Claude to list the issues in your current active sprint through the Jira MCP connection, and confirm the result matches what you see on your live board in the browser.

### Evidence

#### Screenshot 5 — Claude's response showing the live sprint issue list retrieved via Jira MCP

![Week 05 Screenshots](screenshots/week-05-screenshots-54.png)

### Notes You Must Write (Very Important):

How did you confirm this was real board data and not something Claude guessed?

I confirmed this was real board data by comparing Claude's returned sprint issue list with the active sprint shown on my Jira board in the browser. The issue keys, summaries, statuses, assignees, story points, priorities, sprint name, and sprint totals matched the live Jira board. This confirmed that Claude retrieved the information through the Jira MCP rather than generating, assuming, or fabricating the data.

---

# Task 6 — Build the /sprint-health Skill

## Goal

Create a `/sprint-health` skill restricted to read-only Jira tools plus `Read`, with no issue-mutating tools and no `Write`. Run it and confirm it produces a report covering sprint velocity, at-risk stories, and items missing an estimate.

### Evidence

#### Screenshot 6 — `SKILL.md` frontmatter showing `allowed-tools` limited to read-only Jira tools plus `Read`, with `disable-model-invocation: true`

![Week 05 Screenshots](screenshots/week-05-screenshots-55.png)

#### Screenshot 7 — `/sprint-health` output showing the full triage report against your real sprint

![Week 05 Screenshots](screenshots/week-05-screenshots-56.png)

### Notes You Must Write (Very Important):

1. Which Jira MCP tools does this skill's allowed-tools list include, and which mutating tools (create issue, update issue, transition issue, add comment) does it deliberately exclude?

The skill's allowed-tools list includes mcp__jira__jira_search, mcp__jira__jira_get_issue, mcp__jira__jira_get_sprint, mcp__jira__jira_get_board, and Read. These tools are limited to retrieving and analyzing Jira information. The skill deliberately excludes mutating tools such as create issue, update issue, transition issue, and add comment, as well as Write, so it cannot make changes to the Jira board.

2. Why does a Scrum Master need this restriction more than almost any other role in this course?

A Scrum Master needs this restriction because the purpose of the skill is to monitor and assess sprint health, not to make changes to the board. Keeping the skill read-only prevents accidental creation, editing, commenting, or status changes while still providing the Scrum Master with accurate information for decision-making. This keeps Jira changes under human control and ensures that the Scrum Master can review the team's progress and risks without the AI taking action on the team's behalf.

---

# Task 7 — Prove the Skill Never Mutates the Board

## Goal

Manually update one ticket on your board in the browser (for example, move a story to "Done" or add a missing estimate), then run `/sprint-health` again and confirm the new report reflects your change — proving the skill only ever reads live state and never wrote to the board itself.

### Evidence

#### Screenshot 8 — Second `/sprint-health` run showing the report now reflects your manual board change

![Week 05 Screenshots](screenshots/week-05-screenshots-57.pngw)

### Notes You Must Write (Very Important):

Map this assignment to Gather → Analyze → Human Act → Verify from Week 3 Assignment 6. Which step did you perform manually in the browser, and why must that step stay human?

This maps directly to the Gather → Analyze → Human Act → Verify workflow from Week 3 Assignment 6. The /sprint-health skill performs the Gather step by retrieving live Jira data and the Analyze step by calculating sprint health, risks, velocity, and missing information. I performed the Human Act step manually in the Jira browser by changing the issue myself. The Verify step was performed by running /sprint-health again and confirming that the report reflected my manual change. The Human Act step must remain human because the Scrum Master and development team own decisions about changing issue status, estimates, assignments, and other board information. Keeping these actions under human control prevents the AI from making unauthorized changes to the sprint while still allowing it to provide useful analysis.

---

# Submission Instructions

Complete all tasks in sequence.

Your submission must include:
- All 8 required screenshots
- All the required notes

---

# Completion Checklist

- [ ] Task 1: Jira API token created, value never screenshotted (Screenshot 1)
- [ ] Task 2: `.mcp.json` has the Jira server block (Screenshot 2)
- [ ] Task 3: Credentials stored in `settings.local.json`, token blurred, file gitignored (Screenshot 3)
- [ ] Task 4: `/mcp` shows the Jira server connected (Screenshot 4)
- [ ] Task 5: Live query returned real sprint data, verified against the browser (Screenshot 5)
- [ ] Task 6: `/sprint-health` skill created with correct read-only `allowed-tools`, and produced a full report (Screenshots 6–7)
- [ ] Task 7: A manual board change was reflected in a second `/sprint-health` run (Screenshot 8)
- [ ] Skill never created, edited, transitioned, or commented on any issue
- [ ] Reflection answered (Notes)
- [ ] No API token value exposed

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- 🎓 University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- 💬 Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- 📝 Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*
