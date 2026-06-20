# 🚀 vProfile: Jenkins + Elastic Beanstalk CD Pipeline (Production)

This branch contains the **production CD pipeline** that automatically promotes the last successful staging build to the production Beanstalk environment — with zero manual parameter input.

---

## 🆕 What's New vs Ansible Prod Pipeline

| Feature | Ansible Prod Pipeline | Beanstalk Prod Pipeline |
| :--- | :--- | :--- |
| Trigger | Manual with `BUILD` + `TIME` parameters | Automatic — fetches last successful staging build |
| Deployment method | Ansible playbook → EC2 Tomcat | AWS CLI → Beanstalk |
| Artifact source | Nexus repository | S3 (already uploaded by staging pipeline) |
| Parameter input | Manual | Zero — auto-detected |

---

## 🏗 Architecture

```
cicd-jenkins-bean-stage (last successful build)
                ↓
        auto-fetch buildNumber
                ↓
   S3: vprofile-cicd-bean/vprofile-v${buildNumber}.war
                ↓
   Beanstalk update-environment
   (Vpro-beanstalk-prod-env - production)
                ↓
        Slack Notification
```

---

## 🚀 Pipeline Stages

1. **Deploy to Prod Bean**:
   - Auto-fetches `lastSuccessfulBuild.number` from `cicd-jenkins-bean-stage` job
   - Runs `aws elasticbeanstalk update-environment` with that version label
   - No S3 upload needed — artifact already exists from staging pipeline

---

## ⚙️ Environment Variables

| Variable | Value |
| :--- | :--- |
| `ARTIFACT_NAME` | `vprofile-v${buildNumber}.war` |
| `AWS_S3_BUCKET` | `vprofile-cicd-bean` |
| `AWS_EB_APP_NAME` | `vpro-beanstalk` |
| `AWS_EB_ENVIRONMENT` | `Vpro-beanstalk-prod-env` |
| `AWS_EB_APP_VERSION` | `${buildNumber}` |

---

## 🔧 Jenkins Setup Requirements

- **Credentials**: `awsbeancreds` — same IAM credentials as staging
- **Plugin**: `Pipeline: AWS Steps` (`withAWS`)
- **Dependency**: `cicd-jenkins-bean-stage` job must exist and have at least one successful build

---

## 📦 AWS Prerequisites

- S3 bucket: `vprofile-cicd-bean` (shared with staging)
- Elastic Beanstalk application: `vpro-beanstalk`
- Beanstalk production environment: `Vpro-beanstalk-prod-env` (Tomcat platform)
