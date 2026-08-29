# Assignment 6 — Capstone: Deploy Book Review App (Three-Tier Architecture) on Azure

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

This is the most important assignment of the course. You will deploy the Book Review App in a production-ready, best-practice-compliant three-tier architecture on Azure: separated presentation, application, and database tiers, least-privilege network access, a controlled public entry point, protected secrets, and availability/monitoring evidence.

---

# Task 1 — Design the Azure Three-Tier Architecture

## Goal

Create an architecture diagram and implementation plan identifying the presentation, application, and database components, the chosen Azure services, the public entry point, and the internal traffic paths.

### Evidence

#### Screenshot 1 — Architecture diagram showing the public entry point, three tiers, network boundaries, and traffic flow

![Week 07 Screenshots](screenshots/week-07-screenshots-30.png)

---

#### Screenshot 2 — Written architecture assumptions and selected Azure services

![Week 07 Screenshots](screenshots/week-07-screenshots-31.png)

---

# Task 2 — Create the Azure Network Foundation

## Goal

Create a dedicated Resource Group and VNet with separate subnets for the web, application, and database tiers, keeping the application and database tiers without direct public access.

### Evidence

#### Screenshot 3 — Resource Group overview showing the assignment resources

![Week 07 Screenshots](screenshots/week-07-screenshots-32.png)

---

#### Screenshot 4 — VNet overview showing the address space and all required subnets

![Week 07 Screenshots](screenshots/week-07-screenshots-33.png)

---

#### Screenshot 5 — Route-table or Private DNS evidence where applicable

![Week 07 Screenshots](screenshots/week-07-screenshots-34.png)

---

# Task 3 — Configure Security and Secret Management

## Goal

Apply least-privilege NSG rules so traffic flows Internet → public entry point → web tier → application tier → database tier, and store credentials in Azure Key Vault or another approved secure mechanism.

### Evidence

#### Screenshot 6 — NSG rules proving least-privilege access between the tiers

![Week 07 Screenshots](screenshots/week-07-screenshots-35.png)

---

#### Screenshot 7 — Key Vault or approved secret-management configuration (without displaying secret values)

![Week 07 Screenshots](screenshots/week-07-screenshots-36.png)

---

# Task 4 — Deploy the Presentation (Web) Tier

## Goal

Deploy the Book Review App presentation layer on the approved web-tier compute service, configured to route requests to the internal application-tier endpoint, and not directly exposed except through the public entry service.

### Evidence

#### Screenshot 8 — Web-tier compute overview showing subnet and availability configuration

![Week 07 Screenshots](screenshots/week-07-screenshots-37.png)

---

#### Screenshot 9 — Terminal or service output proving the presentation layer is running

![Week 07 Screenshots](screenshots/week-07-screenshots-38.png)

---

# Task 5 — Deploy the Business (Application) Tier

## Goal

Deploy the Book Review App backend privately in the application subnet, configured to use the private database endpoint and secured environment values, reachable only through its internal endpoint.

### Evidence

#### Screenshot 10 — Application-tier compute overview showing private subnet placement

![Week 07 Screenshots](screenshots/week-07-screenshots-39.png)

---

#### Screenshot 11 — Backend process, service, or listening-port evidence

![Week 07 Screenshots](screenshots/week-07-screenshots-40.png)

---

#### Screenshot 12 — Internal health-check or API response (without exposing secrets)

![Week 07 Screenshots](screenshots/week-07-screenshots-41.png)
---

# Task 6 — Deploy the Managed Database Tier

## Goal

Create a private Azure managed database (public access disabled), with availability/backup/retention settings, the Book Review App schema imported, and access restricted to the application tier only.

### Evidence

#### Screenshot 13 — Database overview showing private connectivity and public access disabled

![Week 07 Screenshots](screenshots/week-07-screenshots-42.png)

---

#### Screenshot 14 — Availability, backup, and retention configuration

![Week 07 Screenshots](screenshots/week-07-screenshots-43.png)

---

#### Screenshot 15 — Successful schema or connectivity verification (without exposing credentials)

![Week 07 Screenshots](screenshots/week-07-screenshots-44.png)

---

# Task 7 — Configure Traffic Management, Availability, and Monitoring

## Goal

Configure the approved public entry service with health probes and backend pools, internal routing for the application tier where required, and enable Azure Monitor/diagnostics/logs/alerts for the key resources.

### Evidence

#### Screenshot 16 — Public entry service showing listener, frontend endpoint, and healthy web targets

![Week 07 Screenshots](screenshots/week-07-screenshots-45.png)

---

#### Screenshot 17 — Internal application-tier load-balancing or routing configuration where applicable

![Week 07 Screenshots](screenshots/week-07-screenshots-46.png)

---

#### Screenshot 18 — Azure Monitor, diagnostic settings, logs, metrics, or alert evidence

![Week 07 Screenshots](screenshots/week-07-screenshots-47.png)

---

# Task 8 — Validate the Production-Style Deployment

## Goal

Confirm the Book Review App works end to end through the public endpoint, with at least one database read and one write, confirm private tiers are not internet-reachable, and complete a safe availability test.

### Evidence

#### Screenshot 19 — Browser showing the Book Review App through the public endpoint

![Week 07 Screenshots](screenshots/week-07-screenshots-48.png)

---

#### Screenshot 20 — Proof of successful database-backed read and write operations

![Week 07 Screenshots](screenshots/week-07-screenshots-49.png)

---

#### Screenshot 21 — Evidence that private tiers are not publicly accessible

![Week 07 Screenshots](screenshots/week-07-screenshots-50.png)

---

#### Screenshot 22 — Availability-test and healthy-target evidence

![Week 07 Screenshots](screenshots/week-07-screenshots-51.png)

---

#### Public Endpoint

Paste your public endpoint URL here:

http://40.127.6.205

---

### Notes

Summarize what worked, issues encountered and how they were fixed, and the availability/security/secrets/monitoring/backup choices made.

What worked

The whole three-tier setup came together — VNet with separate subnets for web, app, and database, NSGs locking down what can talk to what, a Public Load Balancer in front of the Web VM and an Internal LB in front of the App VM, and MySQL Flexible Server sitting privately in the VNet. Nginx on the Web VM handles the reverse proxy, so the App tier and database are never exposed to the internet. Both the backend and frontend run under PM2 so they'll survive a reboot. I tested the whole path end to end — reading the books list and registering a new user — and both worked through the public IP.

Issues I ran into

The NAT Gateway needed a "Standard V2" public IP, not "Standard" — Azure's changed this since the walkthrough was recorded.
The homepage was getting a 404 on /api/api/books — turned out the frontend code was already adding /api/ itself, so my env variable was doubling it up. Fixed by leaving the variable empty and rebuilding.
Registration kept failing silently because a different file in the frontend used a different convention for building the API URL, so it was still trying to hit localhost:3001 instead of going through Nginx. Had to fix that file separately so both parts of the app agreed on the same URL pattern.
My home internet's IP kept changing, which quietly broke SSH each time since the NSG rule only allows one specific IP. Had to update it a couple of times mid-project.
First time I ran the backend, it failed because the database book_review_db didn't actually exist inside the MySQL server yet — had to create it manually before anything else would work.
PM2 isn't shared across VMs, so I had to install it separately on each one.

Choices I made

Availability: Both load balancers use health probes, and the Public LB is currently showing 100% healthy instances.
Security: Only the Web VM is public. I confirmed the App VM and database can't be reached from outside Azure at all — the App VM times out and the database's hostname doesn't even resolve outside the VNet.
Secrets: DB credentials and the JWT secret live in a .env file on the App VM, not in the repo. I also set up a Key Vault for secret storage.
Monitoring: Used Azure's Activity Log to track deployment history, and there's a recorded health event showing Azure's own monitoring picked something up and resolved it.
Backup: MySQL is set to 7-day automated backups. I didn't turn on high availability since it wasn't needed for this assignment.




---

# Submission Instructions

- Add all required screenshots and links in your submission
- Do not expose passwords, keys, connection strings, or subscription IDs

---

# Completion Checklist

- [ ] Task 1: Architecture diagram and assumptions documented (Screenshots 1–2)
- [ ] Task 2: Network foundation created with isolated tiers (Screenshots 3–5)
- [ ] Task 3: Least-privilege security and secret management configured (Screenshots 6–7)
- [ ] Task 4: Presentation tier deployed (Screenshots 8–9)
- [ ] Task 5: Application tier deployed privately (Screenshots 10–12)
- [ ] Task 6: Managed database tier deployed privately (Screenshots 13–15)
- [ ] Task 7: Public entry, internal routing, and monitoring configured (Screenshots 16–18)
- [ ] Task 8: End-to-end validation and availability test completed (Screenshots 19–22, Public Endpoint, Notes)
- [ ] No sensitive data exposed

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
