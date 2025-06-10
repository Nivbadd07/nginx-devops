# NGINX DevOps Assignment – Job Interview Project

This repository contains a complete deployment of a Dockerized NGINX web server on AWS, built as part of a DevOps job interview assignment.
The infrastructure is managed using Terraform and includes a public-facing Application Load Balancer (ALB) that routes traffic to a private EC2 instance running NGINX.

The deployed application responds with the message:
**"yo this is nginx"**

---

## Technologies Used

* **Terraform** – Infrastructure as Code
* **AWS Free Tier** – VPC, EC2 (private subnet), ALB (public subnet), NAT Gateway
* **Docker** – Lightweight NGINX container
* **GitHub Actions** – Automated CI/CD workflow (Docker + Terraform)

---

## Project Highlights

* NGINX is deployed in a private subnet
* ALB in the public subnet exposes the service to the internet
* One-click deployment via `terraform apply`
* CI/CD workflow runs automatically on every push to `main`

---

## CI/CD Automation – GitHub Actions

This project includes two GitHub Actions workflows that automate the build and deployment process.

## `build-push.yml`
Triggered when changes are pushed to the `nginx-app/` directory on the `main` branch.

**Steps:**
- Builds the Docker image for the NGINX application.
- Authenticates to DockerHub using GitHub Secrets.
- Pushes the image to DockerHub under `nivbadasshboss/custom-nginx:latest`.

## `deploy.yml`
Triggered on every push to the `main` branch or upon successful completion of the `build-push.yml` workflow.

**Steps:**
- Checks out the repository.
- Initializes and validates Terraform configuration.
- Applies infrastructure changes using `terraform apply -auto-approve`.

## Secrets Used
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

This CI/CD setup ensures consistent and automated deployment of both the Docker image and the infrastructure.

---

## Deployment Guide (Optional)

You can deploy this project in your own AWS account:

```bash
git clone https://github.com/Nivbadd07/nginx-devops.git
cd nginx-devops/terraform
terraform init
terraform apply -auto-approve
```

Ensure your AWS CLI is configured and Terraform is installed.

---

## Architecture Overview

This diagram illustrates the infrastructure layout:


![WhatsApp Image 2025-05-26 at 17 21 26_5f8ebfa9](https://github.com/user-attachments/assets/064f6870-d238-4023-bcf9-53fcfc337d7b)

