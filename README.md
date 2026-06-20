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

---

## 📸 Screenshots

### Architecture
![Architecture](./diagrams/image.png)

### Successful Production Pipeline
![Prod Pipeline](./diagrams/successful_prod_pipeline.png)

### Beanstalk Environments
![Bean Envs](./diagrams/bean_envs.png)

### Application Versions
![App Versions](./diagrams/app_versions.png)
![Apps Versions](./diagrams/apps_versions.png)

### Production Environment (Same Version as Staging)
![Prod Env Same Version](./diagrams/prod_env_same_version_as_stage.png)

### Auto Scaling Groups
![Auto Scaling](./diagrams/prod_stage_auto_scaling_groups.png)

### Load Balancers
![Load Balancers](./diagrams/prod_stage_load_balancers.png)

### All Running Instances
![All Instances](./diagrams/all_running_instances.png)

### Login Page — Production
![Login Prod](./diagrams/login_prod_deploy.png)

### Slack Notification
![Slack](./diagrams/slack_notification.png)
