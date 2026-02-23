# Quick Start Guide

## What Has Been Set Up

Your DevOps project now has a **complete CI/CD pipeline** with **Kubernetes deployment**! Here's what's included:

### ✅ Components Added/Updated:

#### 1. **Kubernetes Manifests** (k8s/ folder)
- `deployment.yml` - 3-replica app deployment with health checks
- `service.yml` - LoadBalancer service for external access
- `hpa.yml` - Auto-scaling (3-10 replicas based on CPU/memory)
- `kustomization.yaml` - Kustomize configuration for manifest management
- `deploy.sh` - Standalone deployment script

#### 2. **Ansible Playbook** (ansible/setup-k8s.yml)
Now configures:
- Docker installation
- Kubernetes setup (kubeadm, kubectl, kubelet)
- Kubernetes cluster initialization
- CNI plugin (Flannel) installation
- Application deployment to Kubernetes

#### 3. **GitHub Actions Pipeline** (.github/workflows/pipeline.yml)
Complete 4-stage pipeline:
1. **Docker Build & Push** - Build and push to Docker Hub
2. **Terraform** - Provision AWS EC2 instance
3. **Ansible** - Configure Kubernetes and deploy app
4. **Verification** - Check deployment status
5. **Summary** - Show deployment details

#### 4. **Documentation**
- `KUBERNETES_GUIDE.md` - Complete setup and troubleshooting guide
- `setup.sh` - Setup verification script
- Updated `.gitignore` - Added more sensitive files

---

## How to Deploy

### Step 1: Set GitHub Secrets
Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:
```
DOCKER_USERNAME     = your-docker-hub-username
DOCKER_PASSWORD     = your-docker-hub-password
AWS_ACCESS_KEY_ID   = your-aws-access-key
AWS_SECRET_ACCESS_KEY = your-aws-secret-key
AWS_REGION          = ap-south-1 (or your preferred region)
EC2_PRIVATE_KEY     = (content of arman-devops-key file)
EC2_PUBLIC_KEY      = (content of arman-devops-key.pub file)
```

### Step 2: Push to Master Branch
```bash
git add .
git commit -m "Add complete Kubernetes setup"
git push origin master
```

### Step 3: Monitor Pipeline
- Go to GitHub → Actions tab
- All stages should run automatically:
  - ✓ Docker build & push
  - ✓ Terraform provision EC2
  - ✓ Ansible setup Kubernetes
  - ✓ Verify deployment

---

## What Happens When You Deploy

```
GitHub Push
    ↓
Docker Image Built & Pushed
    ↓
AWS EC2 Instance Created (t3.micro)
    ↓
Kubernetes Cluster Initialized (single-node)
    ↓
App Deployed with 3 Replicas
    ↓
LoadBalancer Service Exposed
    ↓
Auto-Scaling Configured (3-10 replicas)
    ↓
✓ Application Running!
```

---

## Access Your Application

After deployment completes, SSH into your EC2 instance:

```bash
ssh -i arman-devops-key ec2-user@<PUBLIC_IP>
```

Check the application:
```bash
# Get LoadBalancer IP
kubectl get svc my-devops-app-service -n default --kubeconfig=~/.kube/config

# Check pod status
kubectl get pods -n default --kubeconfig=~/.kube/config

# Check deployment status
kubectl get deployment -n default --kubeconfig=~/.kube/config
```

Access the app via: **http://<LOADBALANCER_IP>**

---

## Key Features

✅ **3-Replica Deployment** - High availability  
✅ **Auto-Scaling** - Scales from 3-10 replicas based on load  
✅ **Health Checks** - Liveness & readiness probes configured  
✅ **LoadBalancer Service** - External access via LoadBalancer  
✅ **Resource Limits** - CPU & memory constraints set  
✅ **Ansible IaC** - Infrastructure as Code with Ansible  
✅ **Terraform IaC** - AWS infrastructure as Code  
✅ **Continuous Deployment** - GitHub Actions automation  
✅ **Kustomize Support** - Easy manifest management  

---

## Project Structure

```
my-devops-project/
├── .github/workflows/
│   └── pipeline.yml              ← Complete CI/CD pipeline
├── k8s/
│   ├── deployment.yml            ← 3-replica deployment
│   ├── service.yml               ← LoadBalancer service
│   ├── hpa.yml                   ← Auto-scaler config
│   ├── kustomization.yaml        ← Manifest management
│   └── deploy.sh                 ← Deploy script
├── ansible/
│   ├── setup-k8s.yml             ← K8s setup playbook
│   └── inventory/                ← Generated inventory
├── terraform/
│   ├── main.tf                   ← AWS resources
│   ├── variables.tf              
│   ├── terraform.tfvars          ← Configuration
│   ├── outputs.tf
│   └── inventory.tpl             ← Ansible inventory template
├── Dockerfile                    ← Docker image
├── index.html                    ← Web app
├── arman-devops-key              ← SSH private key
├── arman-devops-key.pub          ← SSH public key
├── KUBERNETES_GUIDE.md           ← Detailed guide
├── setup.sh                      ← Setup verification
└── .gitignore
```

---

## Troubleshooting

### SSH key not working?
```bash
# Make sure key has correct permissions
chmod 600 arman-devops-key

# Verify it's in secrets as EC2_PRIVATE_KEY
```

### Pods not starting?
```bash
ssh -i arman-devops-key ec2-user@<IP>
kubectl logs <pod-name> -n default --kubeconfig=~/.kube/config
kubectl describe pod <pod-name> -n default --kubeconfig=~/.kube/config
```

### Need to deploy manually?
```bash
ssh -i arman-devops-key ec2-user@<IP>
cd ~/k8s
chmod +x deploy.sh
./deploy.sh
```

---

## Cost Optimization

- **t3.micro**: Free tier eligible
- **Auto-scaling**: Prevents over-provisioning
- **Resource limits**: Controls costs

To clean up when done:
```bash
cd terraform
terraform destroy -auto-approve
```

---

## Next Steps

1. ✅ Set GitHub secrets (see Step 1 above)
2. ✅ Push to master branch
3. ✅ Monitor GitHub Actions
4. ✅ Access your deployed app
5. ✅ Configure custom domain/HTTPS (optional)
6. ✅ Set up monitoring/logging (optional)

---

## See Also

- `KUBERNETES_GUIDE.md` - Comprehensive documentation
- `.github/workflows/pipeline.yml` - Pipeline configuration
- `ansible/setup-k8s.yml` - Kubernetes setup details
- `k8s/` - Kubernetes manifest files

---

**Your DevOps pipeline is ready! 🚀**

Questions? Check `KUBERNETES_GUIDE.md` for detailed troubleshooting and configuration options.
