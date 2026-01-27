# 🚀 vProfile Multitier Java Stack: Automated CI Pipeline

This repository contains the complete **Jenkins CI Pipeline** for the vProfile Java application. The project demonstrates a production-grade DevOps workflow, ensuring every code push is automatically built, analyzed, and stored.

---

## 🏗 System Architecture
The infrastructure is hosted on **AWS EC2**, utilizing a distributed 3-server architecture to ensure resource isolation and optimal performance.

* **Jenkins Server**: Orchestrates the CI pipeline and executes Maven builds.
* **SonarQube Server**: Performs static code analysis and quality gate checks.
* **Nexus Repository Manager**: Manages internal releases and caches external dependencies.

---

## 📂 Project Structure
```text
vprofile-jenkins-ci-automation/
├── src/                    # Java source code (Spring Boot)
│   ├── main/               # Application logic & web assets
│   └── test/               # Unit and Integration tests
├── userdata/               # EC2 Provisioning scripts
├── .gitignore              # Version control exclusions
├── Jenkinsfile             # Declarative Pipeline-as-Code
├── pom.xml                 # Maven Project Configuration
├── README.md               # Project documentation
└── settings.xml            # Nexus authentication configuration

---

## 🚀 Pipeline Workflow 
* Developer Push: Triggered by a GitHub Webhook.

*Build Stage: Compiled using Maven and JDK 17.

*Code Analysis: Analyzed by SonarScanner for security and bugs.

*Quality Gate: Automated check to ensure code meets standards.

*Artifact Upload: .war files versioned and pushed to Nexus.

*Real-time Alerts: Status updates sent to Slack.

---

## 🛠 Project Roadmap (Steps Taken)
* **Phase 1: Infrastructure Setup**
AWS Environment: Configured Security Groups for ports 8080 (Jenkins), 8081 (Nexus), and 9000 (SonarQube).

EC2 Provisioning: Launched instances with UserData scripts for automated tool installation.

Nexus Repositories: Implemented a 4-repo strategy: Proxy, Release, Snapshot, and Group.

* **Phase 2: Pipeline Development**
Git Migration: Migrated source code to a dedicated repository for CI testing.

Maven Integration: Configured settings.xml with credentials for secure Nexus communication.

SonarQube Integration: Configured a "Quality Gate" stage to ensure code meets security standards.

* **Phase 3: Automation & Monitoring**
Webhooks: Enabled GitHub-to-Jenkins triggers for continuous integration.

Slack Integration: Developed a Groovy-based notification block using a COLOR_MAP.

---

##  💻 Tech Stack
*Cloud: AWS (EC2, EBS, Security Groups)

*CI/CD: Jenkins (Declarative Pipeline)

*Build Tool: Maven

*Quality Gate: SonarQube

*Artifacts: Sonatype Nexus

*SCM: GitHub (Webhooks)

*Communication: Slack

---

## 🔧 Infrastructure & Engineering Challenges

| 🚩 Challenge | 📉 Impact | 🛠️ Resolution |
| :--- | :--- | :--- |
| **Nexus Storage Failure** | **500 Internal Server Error** during artifact upload due to 82%+ disk utilization. | Modified AWS EBS volume (8GB → 20GB). Performed a live resize of the **XFS filesystem** using `growpart` and `xfs_growfs` to prevent data loss. |
| **Dependency Latency** | Slow build times (5+ mins) caused by repetitive downloads from Maven Central. | Configured a **Proxy Repository** in Nexus to cache dependencies locally, reducing subsequent build times by **~40%**. |
| **Pipeline Syntax Errors** | Jenkins build failures caused by complex nesting in the `environment` block. | Refactored the **Declarative Jenkinsfile** to resolve Groovy nesting issues and standardized Global Tool paths for JDK 17. |

---

## 📦 How to Use
**Infrastructure**: Provision 3 EC2 instances (Ubuntu/Amazon Linux).

**Setup**: Install JDK 17, Maven, and necessary Jenkins plugins.

**Configuration**: Update environment variables in the Jenkinsfile with your specific server IPs.

**Execution**: Push code to the main branch and monitor the Jenkins dashboard.