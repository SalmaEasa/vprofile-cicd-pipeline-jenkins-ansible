# 🚀 vProfile Multitier Java Stack: Complete CI/CD Pipeline Collection

This repository contains **multiple production-grade Jenkins CI/CD pipelines** for the vProfile Java application, demonstrating two distinct deployment strategies on AWS.

---

## 🗂 Branch Overview

| Branch | Pipeline | Deployment Target |
| :--- | :--- | :--- |
| `cicd-jenkins` | CI only — Build, Test, Sonar, Nexus upload | None |
| `cicd-jenkins-prod` | CD — Manual production deploy | Ansible → EC2 (Tomcat) |
| `cicd-jenkins-bean-stage` | CI/CD — Full pipeline with auto staging deploy | AWS Elastic Beanstalk (Staging) |
| `cicd-jenkins-bean-prod` | CD — Automatic production promotion | AWS Elastic Beanstalk (Production) |
| `main` | Latest merged state | — |

---

## 🏗 Project 1: Jenkins + Ansible Pipeline (cicd-jenkins / cicd-jenkins-prod)

Infrastructure hosted on **AWS EC2** with a distributed 3-server CI architecture and Ansible-based deployment.

![CI/CD Architecture](./digrams%20for%20cicd%20pipeline/cicd_diagram.png)

### Servers
- **Jenkins Server**: Orchestrates the pipeline and triggers Ansible deployments
- **SonarQube Server**: Static code analysis and quality gate checks
- **Nexus Repository Manager**: Artifact storage and dependency caching
- **Staging App Server**: Auto-deployed via Ansible on every CI success
- **Production App Server**: Manually promoted using `BUILD` and `TIME` parameters

### CI/CD Flow
- Developer Push → GitHub Webhook → Jenkins triggered
- Build → Test → Sonar Analysis → Quality Gate
- Upload `.war` to Nexus (versioned as `BUILD_ID-TIMESTAMP`)
- Ansible provisions Tomcat and deploys artifact from Nexus to staging
- Manual trigger on `cicd-jenkins-prod` promotes exact artifact to production

---

## 🏗 Project 2: Jenkins + Elastic Beanstalk Pipeline (cicd-jenkins-bean-stage / cicd-jenkins-bean-prod)

A hybrid cloud-native deployment strategy replacing Ansible+EC2 with **AWS Elastic Beanstalk**, eliminating the need to manage app servers manually.

### What's New
- No Ansible, no app server management — Beanstalk handles infrastructure automatically
- Artifact uploaded directly to **S3**, then deployed to Beanstalk via AWS CLI
- Production pipeline auto-detects the last successful staging build number — no manual parameter entry
- AWS credentials managed securely via Jenkins `awsbeancreds` credential

### CI/CD Flow (Staging)
- Developer Push → GitHub Webhook → Jenkins triggered
- Build → Test → Sonar Analysis → Quality Gate
- Upload `.war` to Nexus + upload to **S3 bucket** (`vprofile-cicd-bean`)
- Create Beanstalk application version from S3
- Deploy to `Vpro-bean-env` (staging environment)

### CD Flow (Production)
- Triggered automatically after staging success
- Auto-fetches `lastSuccessfulBuild` number from the staging job — zero manual input
- Deploys the same S3 artifact version to `Vpro-beanstalk-prod-env`

---

## 📂 Project Structure
```text
vprofile-jenkins-ci-automation/
├── ansible/                        # Ansible playbooks (cicd-jenkins branches)
│   ├── templates/                  # Tomcat service file templates
│   ├── ansible.cfg
│   ├── site.yml                    # Master playbook
│   ├── tomcat_setup.yml
│   ├── vpro-app-setup.yml
│   ├── stage.inventory
│   └── prod.inventory
├── src/                            # Java source code (Spring MVC)
├── userdata/                       # EC2 provisioning scripts
│   ├── jenkins-setup.sh            # Jenkins (Ubuntu)
│   ├── nexus-setup.sh              # Nexus (Amazon Linux 2023)
│   └── sonar-setup.sh              # SonarQube (Ubuntu)
├── Diagrams for ci pipeline/       # CI-only pipeline screenshots
├── digrams for cicd pipeline/      # CI/CD Ansible pipeline screenshots
├── Jenkinsfile                     # Active branch pipeline definition
├── pom.xml
├── README.md
└── settings.xml
```

---

## 💻 Tech Stack

| Layer | Jenkins + Ansible | Jenkins + Beanstalk |
| :--- | :--- | :--- |
| Cloud | AWS EC2, EBS, Route 53 | AWS S3, Elastic Beanstalk, Route 53 |
| CI/CD | Jenkins Declarative Pipeline | Jenkins Declarative Pipeline |
| Deployment | Ansible | AWS CLI + Beanstalk |
| Build | Maven + JDK 11 | Maven + JDK 11 |
| Quality Gate | SonarQube 8.3 | SonarQube 8.3 |
| Artifacts | Sonatype Nexus 3.75 | Sonatype Nexus + S3 |
| App Server | Apache Tomcat 8.5 (self-managed) | Beanstalk-managed Tomcat |
| Notifications | Slack | Slack |

---

## 🔧 Engineering Challenges

| 🚩 Challenge | 📉 Impact | 🛠️ Resolution |
| :--- | :--- | :--- |
| **Nexus CDN Outage** | `latest-unix.tar.gz` returned 404 — provisioning failed | Pinned to `nexus-3.75.1-01` directly from Sonatype CDN |
| **Java/SonarQube Incompatibility** | SonarQube 8.3 crashed with `cglib` reflection errors under Java 21 | Downgraded pipeline to JDK 11 |
| **Jenkins /tmp Disk Threshold** | Node taken offline — `/tmp` tmpfs (980MB) below Jenkins 1GiB threshold | Remounted `/tmp` as 2GB and persisted via `/etc/fstab` |
| **Artifact URL Spaces** | Ansible `get_url` failed — `BUILD_TIMESTAMP` spaces broke Nexus URL | Changed timestamp format to `yyyyMMdd_HHmmss` |
| **Nexus Storage Failure** | 500 error during upload — 82%+ disk utilization | Resized EBS (8GB → 20GB), grew XFS filesystem live |
| **Dependency Latency** | 5+ min builds due to Maven Central downloads | Nexus Proxy Repository reduced build times by ~40% |

---

## 📸 Screenshots

### CI/CD Pipeline (Ansible)
![CI Pipeline](./digrams%20for%20cicd%20pipeline/ci-pipeline.png)
![Prod Pipeline](./digrams%20for%20cicd%20pipeline/prod%20pipeline.png)
![EC2 Instances](./digrams%20for%20cicd%20pipeline/ec2%20instances.png)
![Nexus Repo](./digrams%20for%20cicd%20pipeline/nexus%20repo.png)
![SonarQube](./digrams%20for%20cicd%20pipeline/sonarqube%20passed.png)
![Slack](./digrams%20for%20cicd%20pipeline/slack-notifications.png)
![Route 53](./digrams%20for%20cicd%20pipeline/route53%20records.png)
![Staging App](./digrams%20for%20cicd%20pipeline/login%20page%20using%20app%20stage%20server.png)
![Prod App](./digrams%20for%20cicd%20pipeline/login%20page%20using%20app%20prod%20server.png)
