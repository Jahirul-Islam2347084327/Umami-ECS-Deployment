# Enterprise-Grade Umami Analytics AWS Architecture

A production-ready, highly available, and secure cloud infrastructure deployment for Umami analytics. This project showcases advanced DevOps and Cloud Engineering patterns: implementing absolute Zero-Trust security, automated infrastructure vulnerability scanning, WAF-backed rate limiting, automated Canary deployments with self-healing rollbacks, and multi-metric horizontal auto-scaling entirely via Terraform and GitHub Actions.

<img width="1471" height="1075" alt="image" src="https://github.com/user-attachments/assets/d00b6e8c-9cab-48a5-ab09-8bfc25ff800b" />

## The Cloud Architecture

This repository contains zero application code. It is an infrastructure-only project designed to showcase modern cloud architecture patterns. The system is built to maintain 99.99% uptime, survive availability zone failures, self-heal during faulty code updates, and enforce strict encryption boundaries at every layer.

## Proof of it running

<img width="953" height="527" alt="image" src="https://github.com/user-attachments/assets/12ad2ffa-ade3-4713-ba4e-e41e8a8066fd" />

### Core Architectural Features

* **High Availability Subnet Topology:** A custom AWS VPC spans multiple Availability Zones (AZs). Public subnets isolate the Application Load Balancer (ALB), while ECS Fargate containers and the Amazon RDS database are deep within private subnets with no direct exposure to the internet.
* **TLS Termination & Edge Routing:** Amazon Route 53 acts as the edge router, mapping custom domains securely to the ALB. End-to-end transport layer security is achieved using AWS Certificate Manager (ACM) to provision and automatically renew SSL/TLS certificates for strict HTTPS encryption.
* **Edge Security & Rate Limiting:** An AWS Web Application Firewall (WAF) acts as the frontline shield for the application. It actively monitors request velocities, enforcing granular rate-limiting rules that present an automated CAPTCHA challenge if a suspicious or anomalous volume of traffic targets the infrastructure.
* **Horizontal Compute Autoscaling:** The ECS Fargate tasks scale horizontally automatically. Target tracking scaling policies monitor average CPU and Memory utilization independently, spinning up to 5 container instances during traffic spikes and automatically scaling back down to save costs when traffic settles.
* **Vertical Database Elasticity:** Backed by an Amazon RDS PostgreSQL engine, the database layer scales vertically automatically by dynamically expanding storage volume gigabytes (GB) as data demands grow, eliminating the risk of disk-space depletion crashes.

## Tech Stack

* **Infrastructure as Code:** Terraform (Modular layout isolating network, ecs, rds, alb, waf, and security components)
* **State Management:** S3 Remote Backend with DynamoDB strict State Locking to prevent concurrent execution conflicts
* **Compute Layer:** AWS ECS Fargate (Serverless, managed compute tasks)
* **Database Layer:** Amazon RDS PostgreSQL 16
* **Secrets Management:** AWS Systems Manager (SSM) Parameter Store & AWS Secrets Manager utilizing secure SecureString KMS encryption
* **Security & Compliance:** Trivy Container Scanner & Checkov/tfsec Static Code Analysis
* **CI/CD Pipeline:** GitHub Actions + AWS CodeDeploy (Canary/Linear traffic routing shifts)

## Multi-Stage Layer Optimization & Cache Acceleration
To maximize CI/CD execution speed and compress runtime footprints, the build workflow leverages an advanced multi-stage Docker configuration optimized specifically for engine layer caching. By explicitly separating the copying of dependency manifests (package.json, pnpm-lock.yaml, or prisma schemas) from the rest of the application source code, the Docker engine can freeze and pull pre-cached node dependency layers from cache instead of re-downloading modules on every push. The runtime image completely discards build-essential binaries, compiler engines, and package managers extracting exclusively the pre-compiled production artifacts and system assets into a stripped-down minimal layer. This aggressive dependency isolation structure reduces individual build times inside the GitHub Actions pipeline from minutes to seconds during repeat commits, while crashing the final image size down to a secure, highly-optimized runtime footprint.

## The DevOps Pipeline & Continuous Deployment

The automated deployment pipeline enforces elite security, static testing, and failsafe zero-downtime routing strategies on every git push to main branch.

### 1. Zero-Trust Cloud Authentication

Following the Zero-Trust Principle, the GitHub Actions runner does not store long-lived static AWS access keys or secrets. Instead, it utilizes OpenID Connect (OIDC) to securely log into AWS using dynamic, short-lived tokens, assuming an IAM role with the absolute least privileges required to push images and trigger deployments.

### 2. Pre-Deploy Security Shifting

Before any code reaches AWS, the pipeline runs automated security scanning gates:

* **Trivy Vulnerability Checks:** Scans the newly compiled Docker image layer-by-layer for known CVEs, outdated base packages, or security misconfigurations, failing the build if a vulnerability threshold is breached.
* **Infrastructure Auditing:** Terraform files are automatically parsed to verify security groups are locked down and encryption is enabled across all parameters.

### 3. Failsafe Canary Blue/Green Routing & Self-Healing

Deployments use an advanced AWS CodeDeploy canary strategy instead of basic rolling restarts:

* **The Canary Split:** When a developer pushes a change, a new version of the Fargate container is launched. CodeDeploy routes a small fraction of real web traffic to the new container while keeping the bulk on the stable version.
* **Self-Healing Rollbacks:** The pipeline continuously measures application health during the canary phase. If two consecutive failed health checks are encountered, CodeDeploy instantly halts the deployment and triggers an automated rollback, routing 100% of traffic back to the safe, older version before users notice an outage.
* **Bucket Versioning Recovery:** In worst-case catastrophic scenarios, S3 Bucket Versioning preserves immutable history states of the infrastructure blueprints, allowing instant state rollbacks to any historically verified operational baseline.

## Project Structure

```text
.
├── .github/
│   └── workflows/              # GitHub Actions CI/CD pipeline definitions
│
├── terraform/
│   ├── modules/                # Reusable Infrastructure Blocks
│   │   ├── alb/                # Application Load Balancer templates
│   │   ├── codedeploy/         # Canary deployment definitions
│   │   ├── ecr/                # Container registry configurations
│   │   ├── ecs/                # Fargate Task & Service parameters
│   │   ├── network/            # VPC, Subnets, NAT Gateways, endoints
│   │   ├── rds/                # Relational Database Service definitions
│   │   ├── route53/            # Public Hosted Zones & Alias settings
│   │   ├── security/           # security groups
│   │   └── waf/                # Web Application Firewall rate-limiting rules
│   │
│   └── workflows/              # Targeted Deployment Environments
│       ├── development/
│       │   ├── backend-infra/  # Dev Infrastructure
│       │   └── boilerplate/    # s3 and dynamo
│       ├── staging/            # Staging isolation tier
│       └── production/         # Production live tier
│
└── umami/                      # Application Workspace (Source Hidden)

```

## Deployment Mechanics

To execute the infrastructure initialization sequence:

Move to the infrastructure directory:

```bash
cd terraform/workflows/{choose one the 3 envieroments}/boilerplate

```

Initialize backend drivers, download providers, and bind to the remote S3 lock table:

```bash
terraform init

```

Generate and visually audit the execution dry-run pattern:

```bash
terraform plan

```

Securely apply the blueprint to your cloud provider:

```bash
terraform apply

```

```bash
cd ../backend-infra

```

```bash
terraform init

```

Generate and visually audit the execution dry-run pattern:

```bash
terraform plan

```

Securely apply the blueprint to your cloud provider:

```bash
terraform apply

```

Deployment Strategy
This project utilizes a standard Rolling Deployment strategy to ensure full compatibility with the AWS Free Tier. While the infrastructure is fully configured for advanced traffic shifting, all CodeDeploy-specific modules—including the integrated logic within the ALB, ECS, and main.tf files—are currently commented out to maintain compliance with free tier. Should you wish to implement Canary deployments, these modules can be seamlessly enabled by uncommenting the relevant sections in the ALB module, ECS module, main infrastructure file, and the CI/CD deployment actions.

## Next-Horizon Architectural Goals

To push this cloud platform even closer to an elite enterprise standard, the next architectural iterations will focus on:

* [ ] **Automated Cold Storage Offloading:** Write custom AWS Backup policies or automated cron routines to dump snapshot backups of the live RDS PostgreSQL instance into an isolated, encrypted Amazon S3 bucket.
* [ ] **Dynamic Secrets Rotation:** Configure AWS Secrets Manager to integrate a Lambda function that automatically rotates database credentials every 30 days, modifying the underlying DB system password and updating the ECS Task environment injection strings simultaneously with zero application downtime.
