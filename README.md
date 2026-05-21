# 🚀 vProfile Multitier Java Stack: Automated CI/CD Pipeline

This repository contains the complete **Jenkins CI/CD Pipeline** for the vProfile Java application. The project demonstrates a production-grade DevOps workflow — every code push is automatically built, analyzed, stored, and deployed to staging, with controlled promotion to production.

---

## 🏗 System Architecture

The infrastructure is hosted on **AWS EC2**, utilizing a distributed architecture to ensure resource isolation and optimal performance.

![System Architecture](./digrams%20for%20cicd%20pipeline/cicd_diagram.png)

- **Jenkins Server**: Orchestrates the CI/CD pipeline, executes Maven builds, and triggers Ansible deployments.
- **SonarQube Server**: Performs static code analysis and quality gate checks.
- **Nexus Repository Manager**: Manages internal releases and caches external dependencies.
- **Staging App Server**: Receives automatic deployments on every successful CI build.
- **Production App Server**: Receives controlled manual deployments promoted from staging.

---

## 📂 Project Structure
```text
vprofile-jenkins-ci-automation/
├── ansible/                # Ansible playbooks & inventory
│   ├── templates/          # Tomcat service file templates
│   ├── ansible.cfg         # Ansible configuration
│   ├── site.yml            # Master playbook (tomcat + app deploy)
│   ├── tomcat_setup.yml    # Tomcat 8 installation playbook
│   ├── vpro-app-setup.yml  # Artifact download & deploy playbook
│   ├── stage.inventory     # Staging server inventory
│   └── prod.inventory      # Production server inventory
├── src/                    # Java source code (Spring MVC)
│   ├── main/               # Application logic & web assets
│   └── test/               # Unit and Integration tests
├── userdata/               # EC2 Provisioning scripts
│   ├── jenkins-setup.sh    # Jenkins server setup (Ubuntu)
│   ├── nexus-setup.sh      # Nexus server setup (Amazon Linux 2023)
│   └── sonar-setup.sh      # SonarQube server setup (Ubuntu)
├── Jenkinsfile             # CI + Staging Declarative Pipeline
├── pom.xml                 # Maven Project Configuration
├── README.md               # Project documentation
└── settings.xml            # Nexus authentication configuration
```

---

## 🔀 Branch Strategy

| Branch | Purpose |
| :--- | :--- |
| `main` | CI pipeline — build, test, sonar, upload to Nexus, deploy to staging |
| `cicd-jenkins-prod` | CD pipeline — manual promotion to production with BUILD/TIME parameters |

---

## 🚀 Pipeline Workflow

### CI/CD Pipeline (main branch)
- Developer Push → triggered by GitHub Webhook
- Build: compiled using Maven and JDK 11
- Test: unit tests executed via Maven
- Code Analysis: SonarScanner analyzes for bugs and security issues
- Quality Gate: automated check — pipeline aborts if standards not met
- Artifact Upload: `.war` versioned as `BUILD_ID-TIMESTAMP` and pushed to Nexus
- Ansible Deploy to Staging: Tomcat setup + artifact pulled from Nexus and deployed
- Slack Notification: build result sent to `#jenkinscicd`

### CD Pipeline (cicd-jenkins-prod branch)
- Manually triggered with `BUILD` and `TIME` parameters from a successful staging build
- Ansible deploys the exact same artifact from Nexus to the production server
- Slack Notification: deployment result sent to `#jenkinscicd`

---

## 🛠 Project Roadmap (Steps Taken)

### Phase 1: Infrastructure Setup
- AWS Environment: Configured Security Groups for ports 8080 (Jenkins), 8081 (Nexus), 9000 (SonarQube), and 8080 (Tomcat app servers).
- EC2 Provisioning: Launched instances with UserData scripts for automated tool installation.
- Nexus Repositories: Implemented a 4-repo strategy: Proxy, Release, Snapshot, and Group.

### Phase 2: CI Pipeline Development
- Git Integration: SSH key-based authentication between Jenkins and GitHub.
- Maven Integration: Configured `settings.xml` with credentials for secure Nexus communication.
- SonarQube Integration: Configured Quality Gate stage with webhook callback to Jenkins.
- Artifact Versioning: `.war` files versioned using `BUILD_ID-BUILD_TIMESTAMP`.

### Phase 3: CD Pipeline Development
- Ansible Integration: Jenkins triggers Ansible playbooks to provision Tomcat and deploy artifacts.
- Staging Pipeline: automatic deployment on every successful CI build via webhook.
- Production Pipeline: manual promotion using `BUILD` and `TIME` parameters for controlled releases.

### Phase 4: Automation & Monitoring
- Webhooks: GitHub-to-Jenkins triggers for continuous integration on the main branch.
- Slack Integration: Groovy-based `COLOR_MAP` notification block for build and deployment status.
- Credentials Management: Nexus password secured using Jenkins `credentials()` binding.

---

## 💻 Tech Stack

| Layer | Technology |
| :--- | :--- |
| Cloud | AWS (EC2, EBS, Security Groups, Route 53) |
| CI/CD | Jenkins (Declarative Pipeline) |
| Configuration Management | Ansible |
| Build Tool | Maven + JDK 11 |
| Quality Gate | SonarQube 8.3 |
| Artifacts | Sonatype Nexus 3.75 |
| App Server | Apache Tomcat 8.5 |
| SCM | GitHub (Webhooks) |
| Notifications | Slack |

---

## 🔧 Infrastructure & Engineering Challenges

| 🚩 Challenge | 📉 Impact | 🛠️ Resolution |
| :--- | :--- | :--- |
| **Nexus CDN Outage** | Nexus `latest-unix.tar.gz` returned 404 — instance provisioning failed. | Pinned to last available version `3.75.1-01` directly from Sonatype CDN. |
| **Java/SonarQube Incompatibility** | SonarQube 8.3 crashed on startup with `cglib` reflection errors under Java 21. | Downgraded pipeline to JDK 11 — SonarQube 8.3 only supports Java 11. |
| **Jenkins /tmp Disk Threshold** | Node taken offline — `/tmp` tmpfs (980MB) was below Jenkins' 1GiB threshold. | Remounted `/tmp` as 2GB tmpfs and persisted via `/etc/fstab`. |
| **Artifact URL Spaces** | Ansible `get_url` failed — `BUILD_TIMESTAMP` format contained spaces, breaking the Nexus URL. | Changed Build Timestamp format to `yyyyMMdd_HHmmss` — no spaces, valid URL. |
| **Nexus Storage Failure** | 500 Internal Server Error during artifact upload due to 82%+ disk utilization. | Resized AWS EBS volume (8GB → 20GB) and grew the XFS filesystem live using `growpart` and `xfs_growfs`. |
| **Dependency Latency** | Slow build times (5+ mins) caused by repetitive downloads from Maven Central. | Configured a Proxy Repository in Nexus to cache dependencies locally, reducing build times by ~40%. |

---

## 📦 How to Use

**Infrastructure**: Provision EC2 instances using the `userdata/` scripts:
- Jenkins: Ubuntu — `jenkins-setup.sh`
- Nexus: Amazon Linux 2023 — `nexus-setup.sh`
- SonarQube: Ubuntu — `sonar-setup.sh`
- App Servers (Staging + Prod): Ubuntu — provisioned by Ansible

**Configuration**:
- Update `NEXUSIP` in the Jenkinsfile with your Nexus server private IP
- Update `stage.inventory` and `prod.inventory` with your app server hostnames/IPs
- Add Jenkins credentials: `nexuslogin`, `nexuspass`, `applogin`, `applogin-prod`, `gitlogin`, `slack`
- Configure SonarQube server and scanner in Jenkins Global Tool Configuration

**Execution**:
- Push to `main` → CI/CD pipeline triggers automatically via webhook → deploys to staging
- To deploy to production → manually trigger `cicd-jenkins-prod` pipeline with `BUILD` and `TIME` values from a successful staging build

---

## 📸 Screenshots

### CI Pipeline
![CI Pipeline](./digrams%20for%20cicd%20pipeline/ci-pipeline.png)

### CD Pipeline (Production)
![Prod Pipeline](./digrams%20for%20cicd%20pipeline/prod%20pipeline.png)

### EC2 Instances
![EC2 Instances](./digrams%20for%20cicd%20pipeline/ec2%20instances.png)

### Nexus Repository
![Nexus Repo](./digrams%20for%20cicd%20pipeline/nexus%20repo.png)
![Nexus Central Repo](./digrams%20for%20cicd%20pipeline/nexus%20central%20repo.png)

### SonarQube Quality Gate
![SonarQube Passed](./digrams%20for%20cicd%20pipeline/sonarqube%20passed.png)

### Slack Notifications
![Slack Notifications](./digrams%20for%20cicd%20pipeline/slack-notifications.png)

### Route 53 Records
![Route 53](./digrams%20for%20cicd%20pipeline/route53%20records.png)

### Staging App Server
![Stage App](./digrams%20for%20cicd%20pipeline/stage%20app%20server.png)
![Login Page Staging](./digrams%20for%20cicd%20pipeline/login%20page%20using%20app%20stage%20server.png)

### Production App Server
![Prod App](./digrams%20for%20cicd%20pipeline/app%20prod%20server.png)
![Login Page Production](./digrams%20for%20cicd%20pipeline/login%20page%20using%20app%20prod%20server.png)
