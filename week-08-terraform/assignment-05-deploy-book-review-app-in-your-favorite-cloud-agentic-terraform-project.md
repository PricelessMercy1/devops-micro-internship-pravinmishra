# Capstone Assignment — Deploy the Book Review App Using Terraform and Claude Code Agentic AI

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Student Details

**Full Name:** Aanuoluwapo Tolu-Omodara 
**Cloud Platform:** AWS or Azure : AWS
**GitHub Repository URL:** https://github.com/PricelessMercy1/devops-micro-internship-pravinmishra/  
**Public Application URL / Load-Balancer DNS:** http://book-review-public-alb-1986168851.eu-north-1.elb.amazonaws.com/book/1

---

## Purpose

Deploy the Book Review App using Terraform on AWS or Azure in a secure, highly available, production-style three-tier architecture. Use Claude Code, specialized subagents, Terraform MCP, and validation hooks to support the engineering workflow while keeping all infrastructure-changing operations under human control.

---

# Task 0 — Prepare the Project and Agentic AI Environment

## Goal

Prepare the Book Review App project and configure the provided Claude Code Agentic AI starter kit with project context, specialized subagents, Terraform MCP, validation hooks, and safety guardrails.

## Evidence

### Screenshot 1 — Project `CLAUDE.md`

Add a screenshot of the project `CLAUDE.md` showing the three-tier architecture, security boundaries, Terraform requirements, and human-approval rules.

![Week 08 Screenshots](screenshots/week-08-screenshot-70.png)

---

### Screenshot 2 — Terraform Engineer Subagent

Add a screenshot showing the Terraform Engineer subagent configuration.

![Week 08 Screenshots](screenshots/week-08-screenshot-71.png)


---

### Screenshot 3 — Architecture and Security Reviewer Subagent

Add a screenshot showing the Architecture and Security Reviewer subagent configuration.

![Week 08 Screenshots](screenshots/week-08-screenshot-72.png)


---

### Screenshot 4 — Terraform MCP Connection

Add a screenshot showing Terraform MCP connected and available.

![Week 08 Screenshots](screenshots/week-08-screenshot-73.png)


---

### Screenshot 5 — Validation Hooks

Add a screenshot showing the configured Claude Code validation hooks.

![Week 08 Screenshots](screenshots/week-08-screenshot-74.png)


---

# Task 1 — Design the Three-Tier Architecture

## Goal

Design the required secure, highly available three-tier architecture and create an architecture diagram before building the infrastructure.

The diagram must show:

- VPC or VNet
- Availability Zones or equivalent availability locations
- Six subnets
- Internet connectivity
- NAT or outbound design
- Public load balancer
- Web Tier
- Internal load balancer
- Application Tier
- Managed MySQL
- Read replica
- Main traffic flow

## Architecture Diagram

![Week 08 Screenshots](screenshots/week-08-screenshot-75.png)

---

# Task 2 — Build the Terraform Networking and Security Layers

## Goal

Create the modular Terraform project and implement the network and security layers across the required public and private subnets.

## Evidence

### Screenshot 6 — Modular Terraform Project Structure

Add a screenshot showing the modular Terraform project structure.

![Week 08 Screenshots](screenshots/week-08-screenshot-76.png)


---

### Screenshot 7 — Six-Subnet Architecture

Add a screenshot showing the six-subnet architecture across two availability locations.

![Week 08 Screenshots](screenshots/week-08-screenshot-77.png)


---

### Screenshot 8 — Public and Private Tier Separation

Add a screenshot showing the public and private tier separation, including routing and security boundaries.

![Week 08 Screenshots](screenshots/week-08-screenshot-78.png)


---

# Task 3 — Build the Load-Balancing and Compute Layers

## Goal

Deploy the public and internal load balancers and the Web and Application compute resources required by the Book Review App.

## Evidence

### Screenshot 9 — Web and Application Compute

Add a screenshot showing the Web and Application compute resources in their required subnets.

![Week 08 Screenshots](screenshots/week-08-screenshot-79.png)


---

### Screenshot 10 — Public Load Balancer

Add a screenshot showing the internet-facing public load balancer.

![Week 08 Screenshots](screenshots/week-08-screenshot-80.png)


---

### Screenshot 11 — Internal Load Balancer

Add a screenshot showing the private internal load balancer.

![Week 08 Screenshots](screenshots/week-08-screenshot-81.png)
.

---

### Screenshot 12 — Healthy Targets

Add a screenshot showing healthy target groups or backend pools.

![Week 08 Screenshots](screenshots/week-08-screenshot-82.png)


---

# Task 4 — Build the Managed MySQL Database Layer

## Goal

Deploy a private, highly available managed MySQL database with a read replica and restrict database connectivity to the Application Tier.

## Evidence

### Screenshot 13 — Managed MySQL Database

Add a screenshot showing the managed MySQL database deployment.

![Week 08 Screenshots](screenshots/week-08-screenshot-83.png)


---

### Screenshot 14 — High Availability

Add a screenshot showing the Multi-AZ or high-availability configuration.

![Week 08 Screenshots](screenshots/week-08-screenshot-84.png)


---

### Screenshot 15 — Read Replica

Add a screenshot showing the read replica configuration.

![Week 08 Screenshots](screenshots/week-08-screenshot-85.png)


---

### Screenshot 16 — Private Database Access

Add a screenshot showing that the database is private and accepts MySQL traffic only from the Application Tier.

![Week 08 Screenshots](screenshots/week-08-screenshot-86.png)


---

# Task 5 — Validate, Review, and Apply the Terraform Configuration

## Goal

Validate the Terraform configuration, review the execution plan using both Agentic AI and human judgment, and apply the infrastructure changes only after all required checks pass.

## Evidence

### Screenshot 17 — Terraform Validation

Add a screenshot showing successful `terraform validate` output.

![Week 08 Screenshots](screenshots/week-08-screenshot-87.png)


---

### Screenshot 18 — Terraform Plan

Add a screenshot showing the Terraform plan output.

![Week 08 Screenshots](screenshots/week-08-screenshot-88.png)


---

### Screenshot 19 — Terraform Apply

Add a screenshot showing successful `terraform apply` completion.

![Week 08 Screenshots](screenshots/week-08-screenshot-89.png)


---

# Task 6 — Deploy and Configure the Book Review Application

## Goal

Deploy and configure the Book Review App across the Web, Application, and Database tiers and verify the complete application functionality.

## Evidence

### Screenshot 20 — Homepage

Add a screenshot showing the Book Review App homepage through the public endpoint.

![Week 08 Screenshots](screenshots/week-08-screenshot-90.png)


---

### Screenshot 21 — Login or Authentication

Add a screenshot showing successful login or authentication.

![Week 08 Screenshots](screenshots/week-08-screenshot-91.png)


---

### Screenshot 22 — Book Data

Add a screenshot showing the book listing or book details.

![Week 08 Screenshots](screenshots/week-08-screenshot-92.png)


---

### Screenshot 23 — Review Functionality

Add a screenshot showing the review functionality working successfully.

![Week 08 Screenshots](screenshots/week-08-screenshot-93.png)


---

### Screenshot 24 — Backend or API Evidence

Add a screenshot showing that the backend or API is working successfully.

![Week 08 Screenshots](screenshots/week-08-screenshot-94.png)


---

### Screenshot 25 — Database Reads and Writes

Add a screenshot showing successful database reads and writes.

![Week 08 Screenshots](screenshots/week-08-screenshot-95.png)


## Public Application URL

http://book-review-public-alb-1986168851.eu-north-1.elb.amazonaws.com

---

# Task 7 — Demonstrate the Agentic AI Workflow

## Goal

Demonstrate how Claude Code assisted with Terraform generation, architecture and security review, and evidence-based troubleshooting while infrastructure-changing decisions remained under human control.

You do not need to submit your complete Claude Code conversation history. Include only focused evidence.

## Evidence

### Screenshot 26 — AI-Assisted Terraform Generation

Add a screenshot showing one useful example of AI-assisted Terraform generation or improvement.

![Week 08 Screenshots](screenshots/week-08-screenshot-96.png)


---

### Screenshot 27 — Architecture or Security Review

Add a screenshot showing one structured architecture or security review result.

![Week 08 Screenshots](screenshots/week-08-screenshot-97.png)


---

### Screenshot 28 — AI-Assisted Troubleshooting

Add a screenshot showing one AI-assisted troubleshooting interaction based on collected evidence.

![Week 08 Screenshots](screenshots/week-08-screenshot-98.png)


---

# Task 8 — Complete the Final Architecture Review

## Goal

Review the completed infrastructure against the original capstone requirements and resolve significant architecture, security, reliability, and cost issues.

Confirm that the final review covers:

- Tier separation
- Availability
- Public exposure
- Routing
- Security rules
- Load balancing
- Database privacy
- Secrets
- Terraform quality
- Module structure
- Reliability
- Obvious cost risks

Use Screenshot 27 as the focused evidence for the structured architecture or security review.

---

# Task 9 — Answer the Reflection Questions

## Goal

Reflect on the architecture, Terraform implementation, and Agentic AI workflow. Answer each question briefly in your own words.

## Architecture

### 1. Why did you separate the Web, Application, and Database tiers?

I did that to contain the blast radius of any single compromised layer, if the Web tier is breached, the attacker still can't reach the database directly, since only the App tier's security group is allowed to talk to it. It also lets each tier scale and fail independently.

### 2. Why is the Application Tier private?

It has no reason to be reachable from the internet, all its traffic should arrive through the internal load balancer, from the Web tier only. Keeping it private with no public IP removes an entire attack surface.

### 3. Why is MySQL private?

Database credentials and data are the highest-value target in the stack. Restricting inbound 3306 to only the App tier's security group, with no internet route on the DB subnets at all, means even a fully public misconfiguration elsewhere couldn't expose the database directly.

### 4. Why are multiple Availability Zones used?

A single AZ is a single point of failure, if it goes down, everything in it goes down. Spreading instances, load balancers, and the database across two AZs means the app can survive a full AZ outage.

### 5. What is the difference between Multi-AZ/high availability and a read replica?

Multi-AZ is a synchronous standby purely for failover — it's not queryable, and exists only to take over automatically if the primary fails. A read replica is a separate, queryable instance used to offload read traffic from the primary; it can lag slightly behind since replication is asynchronous.

## Terraform

### 6. How did you divide your Terraform into modules?

I divided them into network, security, load-balancer, database, and compute, each owning one architectural layer, so changes to one (e.g. adding a new security rule) don't require touching unrelated resources.

### 7. How do the modules communicate through variables and outputs?

Each module exposes IDs it creates (subnet IDs, security group IDs, VPC ID) as outputs; the root module wires those outputs into the next module's input variables — e.g. the security module's web_sg_id output feeds into the compute module's security group input.

### 8. What did you specifically check in `terraform plan`?

I checked the exact count and type of resources being added/changed/destroyed, especially confirming zero unintended destroys before any apply; for the security group fix specifically, I checked that only one resource (the new egress rule) was being added and that the referenced security group IDs matched exactly.

## Agentic AI

### 9. What was the purpose of `CLAUDE.md`?

It gave Claude Code persistent project context, the required architecture, security boundaries, and the rule that Claude should never run terraform apply/destroy itself — so every subagent invocation stayed consistent with the plan instead of improvising.

### 10. What work did the Terraform Engineer subagent perform?

It generated the actual .tf resource definitions across all five modules, following the architecture from CLAUDE.md and the modern security-group-rule resource style.

### 11. What did the Architecture and Security Reviewer identify?

It I dentified the security groups with layered rules and made sure the Database tier was completely protected from external access

### 12. Why did you use Terraform MCP instead of relying only on Claude's existing Terraform knowledge?

To ensure the generated resources matched the AWS provider's current documented syntax and best practices rather than potentially outdated patterns from training data — this matters especially for things like the newer separate aws_vpc_security_group_egress_rule resources versus the older inline/rule-resource patterns.

### 13. What was the purpose of your validation hooks?

To enforce deterministic checks (like terraform fmt and validate) automatically rather than relying on remembering to run them manually before every apply.

### 14. Describe one real issue Claude helped you troubleshoot.

SSH from the Web tier to the App tier was timing out during deployment. Claude helped diagnose it as a security-group issue rather than a credentials problem by checking outbound rules on web-sg, discovered port 22 egress was missing, and after adding it we hit a terraform import situation when Terraform tried to duplicate a manually-added Console rule — resolved by importing the existing rule into state instead.

### 15. Describe one recommendation you reviewed, modified, or rejected instead of accepting blindly.

The terraform-engineer subagent suggested running terraform apply -auto-approve when giving manual commands to run — I corrected this every time to plain terraform apply, since -auto-approve skips Terraform's own confirmation prompt, and the project required human approval before every infrastructure change.

---

# Task 10 — Publish the Mandatory LinkedIn Post

## Goal

Publish a LinkedIn post describing the capstone, the technical work completed, the Agentic AI workflow, and the lessons learned.

Write the post in your own words, include at least one project image or other proof, and ensure that it can be viewed by the submission reviewer.

## LinkedIn Post URL

**LinkedIn Post URL:** https://lnkd.in/p/e8UrbbtZ

---

# Submission Instructions

- Complete Tasks 0–10 in sequence.
- Include all Screenshots 1–28 exactly as specified.
- Ensure that your full name is visible in the required screenshots.
- Include the selected cloud platform.
- Include the completed architecture diagram.
- Include the modular Terraform project structure.
- Include the working public application URL or public load-balancer DNS.
- Include all required Agentic AI workflow evidence.
- Answer all 15 reflection questions briefly in your own words.
- Include the published LinkedIn post URL.
- Do not expose cloud credentials, database passwords, SSH private keys, JWT secrets, access tokens, account IDs, Terraform state containing sensitive values, or other confidential information.
- Review all screenshots and project files carefully before submitting through GitHub.

---

# Completion Checklist

- [ ] Selected AWS or Azure
- [ ] Added and reviewed the Agentic AI starter files
- [ ] Configured `CLAUDE.md`
- [ ] Configured the Terraform Engineer subagent
- [ ] Configured the Architecture and Security Reviewer subagent
- [ ] Connected Terraform MCP
- [ ] Configured validation hooks and safety guardrails
- [ ] Created the architecture diagram
- [ ] Created the six-subnet design
- [ ] Configured public Web Tier routing
- [ ] Kept the Application Tier private
- [ ] Kept the Database Tier private
- [ ] Configured tier-specific Security Groups or NSGs
- [ ] Restricted backend port `3001`
- [ ] Restricted MySQL port `3306` to the Application Tier
- [ ] Created the public load balancer
- [ ] Created the internal load balancer
- [ ] Configured listeners and health checks
- [ ] Deployed the Web Tier compute resources
- [ ] Deployed the private Application Tier compute resources
- [ ] Provisioned private managed MySQL
- [ ] Configured Multi-AZ or high availability
- [ ] Configured a read replica
- [ ] Created the modular Terraform project
- [ ] Used variables, outputs, and module dependencies
- [ ] Used current Terraform documentation through MCP
- [ ] Used hooks for deterministic validation
- [ ] Completed `terraform fmt`
- [ ] Completed `terraform validate`
- [ ] Reviewed `terraform plan`
- [ ] Completed the Terraform Engineer review
- [ ] Completed the Architecture and Security review
- [ ] Applied the infrastructure only after human approval
- [ ] Deployed and configured the backend
- [ ] Deployed and configured the frontend
- [ ] Configured Nginx where required
- [ ] Configured the internal backend endpoint
- [ ] Configured the public frontend endpoint
- [ ] Verified the homepage
- [ ] Verified login or authentication
- [ ] Verified book data
- [ ] Verified review functionality
- [ ] Verified the backend API
- [ ] Verified database reads and writes
- [ ] Verified healthy load-balancer targets
- [ ] Included AI-assisted Terraform generation evidence
- [ ] Included one architecture or security review
- [ ] Included one AI-assisted troubleshooting example
- [ ] Completed the final architecture review
- [ ] Answered all 15 reflection questions
- [ ] Published the mandatory LinkedIn post
- [ ] Added the LinkedIn post URL
- [ ] Captured all 28 required screenshots
- [ ] Confirmed that my full name is visible in the required screenshots
- [ ] Checked that no secrets or sensitive information are exposed

---

## About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory), focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations through hands-on experience.

---

## Resources

- Book Review App Repository: [https://github.com/pravinmishraaws/book-review-app](https://github.com/pravinmishraaws/book-review-app)
- DMI Official Website: [https://dmi.pravinmishra.com](https://dmi.pravinmishra.com)
- University: [https://university.pravinmishra.com](https://university.pravinmishra.com)
- Discord Community: [https://discord.pravinmishra.com](https://discord.pravinmishra.com)
- Blog: [https://dmi.pravinmishra.com/blog](https://dmi.pravinmishra.com/blog)
- YouTube Playlist: [https://www.youtube.com/playlist?list=PLFeSNDtI4Cho](https://www.youtube.com/playlist?list=PLFeSNDtI4Cho)
- Pravin Mishra on LinkedIn: [https://www.linkedin.com/in/pravin-mishra-aws-trainer/](https://www.linkedin.com/in/pravin-mishra-aws-trainer/)
- CloudAdvisory on LinkedIn: [https://www.linkedin.com/company/thecloudadvisory/](https://www.linkedin.com/company/thecloudadvisory/)

---

*This submission is part of the DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*
