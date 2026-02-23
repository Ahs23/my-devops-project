# DevOps CI/CD Pipeline with Kubernetes

A **complete automated CI/CD pipeline** that builds Docker images, provisions AWS infrastructure with Terraform, and deploys containerized applications to Kubernetes using Ansible.

![Status Badge](https://img.shields.io/badge/status-production%20ready-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Kubernetes](https://img.shields.io/badge/kubernetes-1.28-blue)
![Terraform](https://img.shields.io/badge/terraform-1.x-blueviolet)
![Ansible](https://img.shields.io/badge/ansible-2.10%2B-red)

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Setup Instructions](#setup-instructions)
- [Project Structure](#project-structure)
- [CI/CD Pipeline](#cicd-pipeline)
- [Kubernetes Configuration](#kubernetes-configuration)
- [Deployment](#deployment)
- [Accessing the Application](#accessing-the-application)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Contributing](#contributing)
- [Documentation](#documentation)

## 🎯 Overview

This project demonstrates enterprise-grade DevOps practices with a fully automated CI/CD pipeline:

- **Build**: Docker containerizes your application
- **Push**: Images are pushed to Docker Hub
- **Provision**: AWS EC2 instance created with Terraform
- **Configure**: Kubernetes cluster setup with Ansible
- **Deploy**: Application deployed to Kubernetes with auto-scaling
- **Verify**: Deployment validated and verified

Perfect for learning DevOps, container orchestration, and infrastructure as code!

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│  (Push to master branch triggers automatic deployment)      │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         │             │             │
         ▼             ▼             ▼
    ┌─────────┐  ┌──────────┐  ┌──────────┐
    │  Docker │  │Terraform │  │ Ansible  │
    │  Build  │  │AWS Infra │  │Setup K8s │
    └────┬────┘  └────┬─────┘  └────┬─────┘
         │             │             │
         └─────────────┼─────────────┘
                       ▼
              ┌──────────────────┐
              │   Docker Hub     │
              │  (Image Registry)│
              └────────┬─────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │     AWS EC2 Instance          │
        │  - t3.micro (Free Tier)       │
        │  - Amazon Linux 2             │
        │  - Security Group             │
        │  - Public IP                  │
        └────────────┬─────────────────┘
                     │
                     ▼
        ┌──────────────────────────────┐
        │  Kubernetes Cluster          │
        │  - Single Node Setup          │
        │  - Flannel CNI                │
        │  - 3 App Replicas             │
        └────────────┬─────────────────┘
                     │
                     ▼
        ┌──────────────────────────────┐
        │  Application (LoadBalancer)  │
        │  my-devops-app:latest        │
        │  - 3 Replicas                │
        │  - HPA (3-10 scaling)         │
        │  - Health Checks              │
        └──────────────────────────────┘
```

## ✨ Features

### 🔄 Continuous Integration & Deployment
- ✅ Automatic builds on push to `master`
- ✅ Docker image builds and pushes to Docker Hub
- ✅ Terraform provisions AWS infrastructure
- ✅ Ansible configures Kubernetes
- ✅ Automatic application deployment

### 🎮 Kubernetes Features
- ✅ 3 replicas for high availability
- ✅ Horizontal Pod Autoscaler (3-10 replicas)
- ✅ LoadBalancer service for external access
- ✅ Liveness & readiness probes
- ✅ Resource requests and limits
- ✅ Self-healing pods

### 🛡️ Infrastructure as Code
- ✅ Terraform for AWS infrastructure
- ✅ Ansible playbooks for configuration
- ✅ Kustomize for Kubernetes manifest management
- ✅ Version controlled everything

### 📊 Monitoring & Reliability
- ✅ Health checks (liveness & readiness)
- ✅ Deployment status verification
- ✅ Pod auto-healing
- ✅ Automatic scaling based on load

## 📦 Prerequisites

### Required Tools (GitHub Actions runs these automatically)
- Git
- GitHub account with repository access
- Docker (for local builds)
- AWS account with billing enabled

### Local Development (Optional)
```bash
# For local testing/deployment
- Terraform >= 1.0
- Ansible >= 2.10
- Docker >= 20.10
- kubectl >= 1.28
- AWS CLI v2
```

### AWS Requirements
- AWS account with EC2, VPC permissions
- IAM user with programmatic access
- Sufficient free tier capacity (or billing enabled)
- ap-south-1 region (or preferred region)

## 🚀 Quick Start

### 1️⃣ Clone Repository
```bash
git clone https://github.com/yourusername/my-devops-project.git
cd my-devops-project
```

### 2️⃣ Set GitHub Secrets
Go to `Settings → Secrets and variables → Actions` and add:

```
DOCKER_USERNAME          # Docker Hub username
DOCKER_PASSWORD          # Docker Hub password (or PAT)
AWS_ACCESS_KEY_ID        # AWS access key
AWS_SECRET_ACCESS_KEY    # AWS secret key
AWS_REGION               # e.g., ap-south-1
EC2_PRIVATE_KEY          # Content of arman-devops-key
EC2_PUBLIC_KEY           # Content of arman-devops-key.pub
```

### 3️⃣ Deploy
```bash
git add .
git commit -m "Deploy DevOps pipeline"
git push origin master
```

### 4️⃣ Monitor
- Go to **Actions** tab in GitHub
- Watch the pipeline execute:
  - Docker build & push
  - Terraform provision
  - Ansible configuration
  - Kubernetes deployment

✅ **That's it!** Your application is deployed to Kubernetes.

---

## 📝 Setup Instructions

### Detailed Setup Guide

For complete setup instructions, including:
- Generating SSH keys
- Creating AWS credentials
- Docker Hub setup
- GitHub secrets configuration
- Local testing

See [QUICKSTART.md](./QUICKSTART.md)

### Step-by-Step Configuration

1. **SSH Keys** (if you don't have them)
   ```bash
   ssh-keygen -t rsa -b 4096 -f arman-devops-key -N ""
   ```

2. **Docker Hub Setup**
   - Create Docker Hub account
   - Create Personal Access Token (Settings → Security)
   - Note username and token

3. **AWS Setup**
   - Create AWS account (or use existing)
   - Create IAM user with EC2 permissions
   - Generate access keys
   - Note key ID and secret key

4. **GitHub Secrets**
   - Copy all values to GitHub repository secrets (see Quick Start Step 2)

5. **Test the Pipeline**
   - Push to master branch
   - Pipeline runs automatically
   - Check Actions tab for progress

---

## 📁 Project Structure

```
my-devops-project/
├── .github/
│   └── workflows/
│       └── pipeline.yml              ← Main CI/CD pipeline
├── k8s/                              ← Kubernetes manifests
│   ├── deployment.yml                ← App deployment (3 replicas)
│   ├── service.yml                   ← LoadBalancer service
│   ├── hpa.yml                       ← Auto-scaling config
│   ├── kustomization.yaml            ← Manifest management
│   └── deploy.sh                     ← Deployment script
├── ansible/
│   ├── setup-k8s.yml                 ← Kubernetes setup playbook
│   └── inventory/
│       └── hosts.ini                 ← Generated inventory
├── terraform/
│   ├── main.tf                       ← AWS infrastructure
│   ├── variables.tf                  ← Variable definitions
│   ├── terraform.tfvars              ← Configuration values
│   ├── outputs.tf                    ← Output definitions
│   └── inventory.tpl                 ← Ansible inventory template
├── arman-devops-key                  ← SSH private key (⚠️ DO NOT COMMIT)
├── arman-devops-key.pub              ← SSH public key
├── Dockerfile                        ← Docker image definition
├── index.html                        ← Web application
├── .gitignore                        ← Git ignore rules
├── README.md                         ← This file
├── QUICKSTART.md                     ← Quick reference guide
├── KUBERNETES_GUIDE.md               ← Detailed K8s guide
└── setup.sh                          ← Setup verification script

```

---

## 🔄 CI/CD Pipeline

### Pipeline Stages

#### 1. **Docker Build & Push** 🐳
- Builds Docker image from Dockerfile
- Tags with `latest` and commit SHA
- Pushes to Docker Hub
- Requires: `DOCKER_USERNAME`, `DOCKER_PASSWORD`

#### 2. **Terraform Provision** 🏗️
- Initializes Terraform
- Creates AWS resources:
  - VPC Security Group (SSH, HTTP, HTTPS)
  - EC2 Key Pair
  - EC2 Instance (t3.micro)
- Outputs public IP
- Requires: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`

#### 3. **Ansible Configuration** ⚙️
- Waits for EC2 to be SSH-ready
- Installs Docker
- Installs Kubernetes (kubeadm, kubelet, kubectl)
- Initializes single-node K8s cluster
- Installs Flannel CNI plugin
- Requires: `EC2_PRIVATE_KEY`

#### 4. **Application Deployment** 🚀
- Generates Ansible inventory from Terraform outputs
- Runs Ansible playbook
- Deploys application to Kubernetes:
  - Deployment (3 replicas)
  - LoadBalancer service
  - HorizontalPodAutoscaler (3-10 replicas)

#### 5. **Verification & Summary** ✅
- Checks Kubernetes cluster status
- Verifies pods are running
- Displays deployment information
- Provides access details

### Pipeline Triggers
- Push to `master` branch
- Manual trigger via Actions tab

### Pipeline Duration
- Typical: **5-8 minutes**
- Docker build: 1-2 minutes
- Terraform: 1-2 minutes
- Kubernetes setup: 2-3 minutes
- Deployment: 1-2 minutes

---

## ☸️ Kubernetes Configuration

### Deployment Spec
```yaml
- Name: my-devops-app
- Replicas: 3
- Image: armanshaikh23/my-devops-app:latest
- Port: 80 (HTTP)
- Resources:
  - Requests: 64Mi memory, 100m CPU
  - Limits: 128Mi memory, 500m CPU
- Health Checks:
  - Liveness: HTTP GET / every 10s (30s delay)
  - Readiness: HTTP GET / every 5s (5s delay)
```

### Service Configuration
```yaml
- Type: LoadBalancer
- Port: 80
- Target Port: 80
- Protocol: TCP
```

### Auto-Scaling Configuration
```yaml
- Type: HorizontalPodAutoscaler
- Min Replicas: 3
- Max Replicas: 10
- CPU Threshold: 70%
- Memory Threshold: 80%
```

---

## 🚀 Deployment

### Automatic Deployment (Recommended)
1. Make changes and push to master
2. Pipeline runs automatically
3. Application deployed automatically

### Manual Deployment (SSH)
```bash
# SSH into EC2 instance
ssh -i arman-devops-key ec2-user@<PUBLIC_IP>

# Navigate to manifests
cd ~/k8s

# Deploy
kubectl apply -f deployment.yml --kubeconfig=~/.kube/config
kubectl apply -f service.yml --kubeconfig=~/.kube/config
kubectl apply -f hpa.yml --kubeconfig=~/.kube/config

# Check status
kubectl get all -n default --kubeconfig=~/.kube/config
```

### Local Deployment (with Kubernetes cluster)
```bash
# If you have a local K8s cluster (minikube, etc.)
kubectl apply -f k8s/
kubectl get pods -n default
kubectl get svc -n default
```

---

## 📱 Accessing the Application

### Get LoadBalancer IP
```bash
# SSH into EC2
ssh -i arman-devops-key ec2-user@<PUBLIC_IP>

# Get service details
kubectl get svc my-devops-app-service -n default --kubeconfig=~/.kube/config
```

### Access via Browser
```
http://<LOADBALANCER_IP>
```

### Check Pod Status
```bash
# List pods
kubectl get pods -n default --kubeconfig=~/.kube/config

# View logs
kubectl logs <pod-name> -n default --kubeconfig=~/.kube/config

# Describe pod
kubectl describe pod <pod-name> -n default --kubeconfig=~/.kube/config
```

---

## 🔧 Troubleshooting

### GitHub Actions Shows Errors

#### Docker Build Fails
- **Check**: DOCKER_USERNAME and DOCKER_PASSWORD secrets
- **Fix**: Recreate secrets in GitHub Settings
- **Note**: Use Personal Access Token (PAT) instead of password

#### Terraform Fails
- **Check**: AWS credentials and region
- **Check**: AWS account has permission for EC2
- **Fix**: Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

#### Ansible SSH Connection Fails
- **Check**: EC2_PRIVATE_KEY secret matches EC2_PUBLIC_KEY
- **Check**: Keys were generated correctly
- **Fix**: Re-generate SSH key pair:
  ```bash
  ssh-keygen -t rsa -b 4096 -f arman-devops-key -N ""
  ```

#### Kubernetes Pods Won't Start
- **Check**: Pod logs for errors
  ```bash
  kubectl logs <pod-name> -n default
  ```
- **Check**: Docker image exists on Docker Hub
- **Check**: Pod has enough resources (CPU/memory)

### Kubernetes Issues

#### LoadBalancer IP is Pending
```bash
# This is normal - takes a few minutes
# Check again:
kubectl get svc -n default

# Alternative: Use NodePort instead
kubectl edit svc my-devops-app-service -n default
# Change: type: LoadBalancer → type: NodePort
```

#### Node Not Ready
```bash
# Check node status
kubectl get nodes

# Check kubelet logs
sudo journalctl -u kubelet -n 50

# Restart kubelet
sudo systemctl restart kubelet
```

#### Nodes Disconnected
```bash
# SSH into EC2 and check network
ssh -i arman-devops-key ec2-user@<IP>

# Verify Docker is running
docker ps

# Check system resources
df -h
free -h
```

### Common Fixes

1. **SSH Connection Timeout**
   - Verify security group allows port 22
   - Check instance is running
   - Wait 2-3 minutes for instance to boot

2. **Docker Hub Push Fails**
   - Check internet connection
   - Verify credentials are correct
   - Check Docker Hub quota

3. **EC2 Instance Not Found**
   - Check AWS region matches in `terraform.tfvars`
   - Verify AWS credentials have EC2 permissions
   - Check AWS account isn't in limited state

### Debug Commands

```bash
# Check pipeline logs
# GitHub Actions → Workflow run → Logs

# Check EC2 instance
aws ec2 describe-instances --region ap-south-1

# SSH into instance and check
ssh -i arman-devops-key ec2-user@<IP>

# Inside EC2:
docker ps                    # Check Docker containers
kubectl get all -n default   # Check K8s resources
sudo systemctl status docker # Check Docker service
sudo systemctl status kubelet # Check kubelet service
```

---

## 🗑️ Cleanup

### Complete Cleanup
```bash
# This will DELETE all AWS resources and stop charges

cd terraform
terraform destroy -auto-approve
```

### Partial Cleanup
```bash
# Destroy EC2 only (keep VPC, etc.)
cd terraform
terraform apply -destroy -auto-approve -target=aws_instance.devops_server
```

### Cost Monitoring
- Monitor AWS usage: https://console.aws.amazon.com/billing/
- Set up billing alerts to avoid unexpected charges
- Free tier includes 750 hours/month for t3.micro

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Commit with clear messages (`git commit -m 'Add feature'`)
5. Push to branch (`git push origin feature/improvement`)
6. Open a Pull Request

### Guidelines
- Follow existing code style
- Update documentation with changes
- Test changes locally if possible
- Include meaningful commit messages

---

## 📚 Documentation

### Included Documentation
- **README.md** (this file) - Project overview and setup
- **QUICKSTART.md** - Quick reference and getting started
- **KUBERNETES_GUIDE.md** - Comprehensive K8s setup and troubleshooting

### External Resources
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 👨‍💻 Author

Arman Shaikh  
- Docker Hub: [@armanshaikh23](https://hub.docker.com/u/armanshaikh23)

---

## 🙋 Support

### Having Issues?

1. **Check Documentation**
   - Read QUICKSTART.md for quick fixes
   - See KUBERNETES_GUIDE.md for detailed guides

2. **Review Logs**
   - GitHub Actions workflow logs
   - Check EC2 system logs via AWS Console
   - SSH into instance for detailed logs

3. **Search Known Issues**
   - Check GitHub Issues in this repository
   - Review troubleshooting section above

4. **Get Help**
   - Create a GitHub Issue with:
     - Error messages
     - Steps to reproduce
     - Screenshots/logs
     - Your environment details

---

## 🎓 Learning Resources

This project demonstrates:
- ✅ Docker containerization
- ✅ GitHub Actions CI/CD
- ✅ Terraform Infrastructure as Code
- ✅ Ansible Configuration Management
- ✅ Kubernetes container orchestration
- ✅ AWS cloud deployment
- ✅ DevOps best practices

Perfect for learning DevOps!

---

## 🚨 Security Notes

⚠️ **IMPORTANT**
- Never commit SSH keys (they're in .gitignore)
- Never commit AWS credentials
- Rotate keys regularly
- Use IAM roles instead of access keys when possible
- Restrict security group to your IP in production
- Enable HTTPS/TLS in production deployments
- Implement Kubernetes RBAC for production

---

## 📈 Roadmap

Planned improvements:
- [ ] HTTPS/TLS support
- [ ] Multi-region deployment
- [ ] Database integration
- [ ] Monitoring & logging stack (Prometheus/Grafana)
- [ ] Helm chart support
- [ ] GitOps with ArgoCD
- [ ] Automated backups
- [ ] Cost optimization automation

---

**Happy deploying! 🎉**

For more information, see the [documentation](#documentation) section or check the included guides.

---

<div align="center">

**[Quick Start](./QUICKSTART.md)** • **[K8s Guide](./KUBERNETES_GUIDE.md)** • **[GitHub](https://github.com/yourusername/my-devops-project)**

Made with ❤️ for DevOps enthusiasts

</div>
