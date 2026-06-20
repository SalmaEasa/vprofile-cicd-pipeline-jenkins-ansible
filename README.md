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

## 🏗 Project 1: Jenkins + Ansible Pipeline

Branches: `cicd-jenkins` → `cicd-jenkins-prod`

Infrastructure hosted on **AWS EC2** with a distributed 3-server CI architecture and Ansible-based deployment to self-managed Tomcat servers.

### Flow
```
GitHub Push → Jenkins → Build → Test → SonarQube → Quality Gate
                                                         ↓
                                               Nexus (versioned .war)
                                                         ↓
                                    Ansible → Tomcat (Staging EC2)
                                                         ↓
                                    Manual trigger → Tomcat (Prod EC2)
                                                         ↓
                                               Slack Notification
```

### Key Components
- Jenkins, SonarQube, Nexus — each on dedicated EC2 instances
- Ansible provisions Tomcat and pulls artifact from Nexus
- Production deploy is manual — triggered with `BUILD` and `TIME` parameters

---

## 🏗 Project 2: Jenkins + Elastic Beanstalk Pipeline

Branches: `cicd-jenkins-bean-stage` → `cicd-jenkins-bean-prod`

A cloud-native deployment strategy replacing Ansible+EC2 with **AWS Elastic Beanstalk**, eliminating manual server management entirely.

### What's New vs Project 1

| Feature | Jenkins + Ansible | Jenkins + Beanstalk |
| :--- | :--- | :--- |
| App server management | Manual (Tomcat on EC2) | Fully managed by Beanstalk |
| Deployment method | Ansible playbook | AWS CLI → S3 → Beanstalk |
| Artifact storage | Nexus only | Nexus + S3 |
| Prod trigger | Manual with parameters | Auto — fetches last successful staging build |

### Flow
```
GitHub Push → Jenkins → Build → Test → SonarQube → Quality Gate
                                                         ↓
                                               Nexus + S3 (.war)
                                                         ↓
                                    Beanstalk create-application-version
                                                         ↓
                                    Beanstalk update-environment (Staging)
                                                         ↓
                                    Auto-promote → Beanstalk (Production)
                                                         ↓
                                               Slack Notification
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
| **Java/SonarQube Incompatibility** | SonarQube 8.3 crashed with `cglib` errors under Java 21 | Downgraded pipeline to JDK 11 |
| **Jenkins /tmp Disk Threshold** | Node taken offline — `/tmp` tmpfs below 1GiB threshold | Remounted `/tmp` as 2GB, persisted via `/etc/fstab` |
| **Artifact URL Spaces** | Ansible `get_url` failed — `BUILD_TIMESTAMP` spaces broke Nexus URL | Changed timestamp format to `yyyyMMdd_HHmmss` |
| **Nexus Storage Failure** | 500 error during upload — 82%+ disk utilization | Resized EBS (8GB → 20GB), grew XFS filesystem live |
| **Dependency Latency** | 5+ min builds due to Maven Central downloads | Nexus Proxy Repository reduced build times by ~40% |

---

## 📸 Screenshots (Project 1 — Jenkins + Ansible)

### CI/CD Pipeline
![CI Pipeline](./digrams%20for%20cicd%20pipeline/ci-pipeline.png)

### Production Pipeline
![Prod Pipeline](./digrams%20for%20cicd%20pipeline/prod%20pipeline.png)

### EC2 Instances
![EC2 Instances](./digrams%20for%20cicd%20pipeline/ec2%20instances.png)

### Nexus Repository
![Nexus Repo](./digrams%20for%20cicd%20pipeline/nexus%20repo.png)

### SonarQube Quality Gate
![SonarQube](./digrams%20for%20cicd%20pipeline/sonarqube%20passed.png)

### Route 53 Records
![Route 53](./digrams%20for%20cicd%20pipeline/route53%20records.png)

### Login Page — Staging
![Login Staging](./digrams%20for%20cicd%20pipeline/login%20page%20using%20app%20stage%20server.png)

### Login Page — Production
![Login Prod](./digrams%20for%20cicd%20pipeline/login%20page%20using%20app%20prod%20server.png)

### Slack Notifications
![Slack](./digrams%20for%20cicd%20pipeline/slack-notifications.png)

---

> 📌 For Project 2 (Jenkins + Beanstalk) screenshots, switch to the `cicd-jenkins-bean-stage` branch.
