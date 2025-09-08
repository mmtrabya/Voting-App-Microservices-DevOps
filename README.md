# 🗳️ Voting App – Microservices with DevOps Pipeline

This project implements a **Voting Application** using a **microservices architecture** deployed on **AWS EKS**.  
The solution is fully automated using **Terraform**, **CI/CD pipelines (GitHub Actions + Argo CD)**.

---

## 🚀 Architecture Overview

### 🔧 Key Components
- **Microservices**
  - Python Service 🐍
  - Node.js Service 🌐
  - .NET Service ⚙️
  - Redis Queue 🔴
  - PostgreSQL Database 🐘

- **Containerization**
  - Docker 🐳 builds and pushes images to Docker Hub
  - Kubernetes deploys microservices to **EKS**

- **Infrastructure as Code (IaC)**
  - Terraform provisions:
    - EKS Cluster
    - S3 Bucket
    - IAM Roles

- **CI/CD**
  - GitHub Actions triggers build/test pipelines
  - Argo CD deploys applications to Kubernetes
