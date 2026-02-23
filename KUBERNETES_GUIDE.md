# DevOps Project - Kubernetes Deployment Guide

## Overview
This project includes a complete CI/CD pipeline that provisions an AWS EC2 instance with Kubernetes and deploys a containerized application.

## Architecture

```
GitHub Repository
    ↓
    CI/CD Pipeline (GitHub Actions)
    ├─ Docker Build & Push
    ├─ Terraform (AWS Infrastructure)
    └─ Ansible (Kubernetes Setup & Deployment)
    ↓
AWS EC2 Instance
    ├─ Docker
    ├─ Kubernetes (kubeadm)
    └─ my-devops-app (3 Replicas)
```

## Project Structure

```
my-devops-project/
├── .github/workflows/
│   └── pipeline.yml              # GitHub Actions CI/CD pipeline
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yml            # Kubernetes Deployment
│   ├── service.yml               # Kubernetes Service (LoadBalancer)
│   ├── hpa.yml                   # Horizontal Pod Autoscaler
│   ├── kustomization.yaml        # Kustomize configuration
│   └── deploy.sh                 # Deployment script
├── ansible/
│   └── setup-k8s.yml             # Ansible playbook for K8s setup
├── terraform/
│   ├── main.tf                   # AWS infrastructure
│   ├── variables.tf              # Variable definitions
│   ├── terraform.tfvars          # Variable values
│   ├── outputs.tf                # Output definitions
│   └── inventory.tpl             # Ansible inventory template
├── Dockerfile                     # Docker image definition
├── index.html                     # Web application
├── arman-devops-key              # SSH private key (DO NOT COMMIT)
└── arman-devops-key.pub          # SSH public key

```

## Prerequisites

### Local Setup
- GitHub account with repository access
- AWS account with appropriate permissions
- SSH keys generated (`arman-devops-key` and `arman-devops-key.pub`)
- Git installed
- (Optional) Terraform, Ansible, Docker for local testing

### GitHub Secrets Required
Create the following secrets in your GitHub repository settings:

```
DOCKER_USERNAME          # Docker Hub username
DOCKER_PASSWORD          # Docker Hub password
AWS_ACCESS_KEY_ID        # AWS access key
AWS_SECRET_ACCESS_KEY    # AWS secret key
AWS_REGION               # AWS region (default: ap-south-1)
EC2_PRIVATE_KEY          # Content of arman-devops-key
EC2_PUBLIC_KEY           # Content of arman-devops-key.pub
```

## Pipeline Workflow

### 1. Docker Stage
- Checks out code
- Sets up Docker Buildx
- Logs into Docker Hub
- Builds and pushes image with tags:
  - `armanshaikh23/my-devops-app:latest`
  - `armanshaikh23/my-devops-app:<commit-sha>`

### 2. Infrastructure Stage (Terraform)
- Initializes Terraform
- Creates/updates AWS resources:
  - VPC Security Group (SSH, HTTP, HTTPS)
  - EC2 Key Pair
  - EC2 Instance (t3.micro, Amazon Linux 2, ap-south-1)
- Outputs the public IP address

### 3. Configuration Stage (Ansible)
- Waits for EC2 instance to be ready (SSH accessible)
- Installs and configures:
  - Docker
  - Kubernetes (kubeadm, kubectl, kubelet)
  - Flannel CNI plugin
- Initializes Kubernetes cluster
- Deploys application with:
  - 3 replicas of my-devops-app
  - LoadBalancer service
  - HPA (scales 3-10 replicas based on CPU/Memory)

### 4. Verification Stage
- Validates Kubernetes cluster status
- Checks deployed pods and services
- Provides deployment summary

## Kubernetes Configuration

### Deployment
- **Image**: `armanshaikh23/my-devops-app:latest`
- **Replicas**: 3 (managed by HPA: 3-10)
- **Port**: 80
- **Resources**:
  - Requests: 64Mi memory, 100m CPU
  - Limits: 128Mi memory, 500m CPU
- **Health Checks**:
  - Liveness probe: HTTP GET / every 10s (30s initial delay)
  - Readiness probe: HTTP GET / every 5s (5s initial delay)

### Service
- **Type**: LoadBalancer
- **Port**: 80
- **Protocol**: TCP

### Autoscaling (HPA)
- **Min Replicas**: 3
- **Max Replicas**: 10
- **Metrics**:
  - CPU utilization: 70%
  - Memory utilization: 80%

## How to Deploy

### Option 1: Automatic (GitHub Actions)
1. Push changes to `master` branch
2. GitHub Actions automatically:
   - Builds and pushes Docker image
   - Provisions AWS infrastructure
   - Sets up Kubernetes
   - Deploys application

### Option 2: Manual Deployment (on EC2)

```bash
# SSH into EC2 instance
ssh -i arman-devops-key ec2-user@<PUBLIC_IP>

# Apply Kubernetes manifests
cd ~/k8s
kubectl apply -f deployment.yml --kubeconfig=~/.kube/config
kubectl apply -f service.yml --kubeconfig=~/.kube/config
kubectl apply -f hpa.yml --kubeconfig=~/.kube/config

# Check status
kubectl get deployments -n default --kubeconfig=~/.kube/config
kubectl get pods -n default --kubeconfig=~/.kube/config
kubectl get svc -n default --kubeconfig=~/.kube/config
```

## Accessing the Application

1. Check the LoadBalancer IP:
```bash
ssh -i arman-devops-key ec2-user@<PUBLIC_IP>
kubectl get svc my-devops-app-service -n default --kubeconfig=~/.kube/config
```

2. Access the application:
```
http://<LOADBALANCER_IP>
```

## Troubleshooting

### Pipeline Fails at Ansible Step
- **Issue**: SSH authentication fails
- **Solution**: Verify that `EC2_PRIVATE_KEY` and `EC2_PUBLIC_KEY` secrets are updated with your keys

### Pods not starting
```bash
# Check pod logs
kubectl logs <pod-name> -n default --kubeconfig=~/.kube/config

# Describe pod for events
kubectl describe pod <pod-name> -n default --kubeconfig=~/.kube/config
```

### Kubernetes cluster not ready
```bash
# Check node status
kubectl get nodes --kubeconfig=~/.kube/config

# Check kubelet status
sudo systemctl status kubelet

# Check system pods
kubectl get pods -n kube-system --kubeconfig=~/.kube/config
```

### LoadBalancer IP is pending
- This is normal for AWS EC2. The IP may take a few minutes to be assigned.
- For EC2 without ELB, you can use NodePort instead:
  ```bash
  kubectl edit svc my-devops-app-service -n default --kubeconfig=~/.kube/config
  # Change: type: LoadBalancer → type: NodePort
  ```

## Environment Variables

The pipeline uses the following environment variables:
- AWS region: `ap-south-1` (configurable in variables.tf)
- Instance type: `t3.micro` (configurable in variables.tf)
- Kubernetes pod network: `10.244.0.0/16`
- Docker image: `armanshaikh23/my-devops-app`

## Security Notes

⚠️ **Important Security Considerations**:

1. **Never commit SSH keys** to the repository (they're in .gitignore)
2. **Rotate keys regularly** in production
3. **Use AWS IAM** instead of access keys (use roles when possible)
4. **Restrict security group** access to your IP only
5. **Enable HTTPS** in production
6. **Implement RBAC** in Kubernetes for production
7. **Use secrets management** for sensitive data

## Cost Optimization

- **Instance type**: t3.micro (eligible for AWS free tier)
- **Horizontal Pod Autoscaler**: Prevents unnecessary resources
- **Resource requests/limits**: Prevents resource waste
- **Consider**: Spot instances, Reserved instances for production

## Cleanup

To destroy all AWS resources and avoid charges:

```bash
cd terraform
terraform destroy -auto-approve
```

## Support

For issues or questions:
1. Check GitHub Actions workflow logs
2. SSH into EC2 for manual inspection
3. Review Ansible playbook output
4. Check Kubernetes pod logs

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Ansible Kubernetes Module](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/index.html)
- [GitHub Actions](https://github.com/features/actions)
