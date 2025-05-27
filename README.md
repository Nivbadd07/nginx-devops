# NGINX DevOps Assignment – Job Interview Project

This repository contains a complete deployment of a Dockerized NGINX web server on AWS, built as part of a DevOps job interview assignment.
The infrastructure is managed using Terraform and includes a public-facing Application Load Balancer (ALB) that routes traffic to a private EC2 instance running NGINX.

The deployed application responds with the message:
**"yo this is nginx"**

---

## Live Deployment

**URL:** [http://nginx-alb-406501829.us-east-1.elb.amazonaws.com](http://nginx-alb-406501829.us-east-1.elb.amazonaws.com)

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

