#!/bin/bash
# Setup script for DevOps project deployment

set -e

echo "=========================================="
echo "DevOps Project Setup Script"
echo "=========================================="
echo ""

# Check for required tools
echo "Checking required tools..."

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi
echo "✓ Terraform found"

if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed"
    exit 1
fi
echo "✓ Ansible found"

if ! command -v aws &> /dev/null; then
    echo "⚠️  AWS CLI not found (optional for local deployment)"
fi
echo "✓ AWS CLI (optional)"

if ! command -v ssh &> /dev/null; then
    echo "❌ SSH is not installed"
    exit 1
fi
echo "✓ SSH found"

# Check SSH keys
echo ""
echo "Checking SSH keys..."

if [ ! -f "arman-devops-key" ]; then
    echo "❌ Private key not found: arman-devops-key"
    exit 1
fi
echo "✓ Private key found"

if [ ! -f "arman-devops-key.pub" ]; then
    echo "❌ Public key not found: arman-devops-key.pub"
    exit 1
fi
echo "✓ Public key found"

# Verify key permissions
chmod 600 arman-devops-key
echo "✓ SSH key permissions set correctly (600)"

# Check directory structure
echo ""
echo "Checking project structure..."

for dir in terraform ansible k8s .github/workflows; do
    if [ ! -d "$dir" ]; then
        echo "❌ Missing directory: $dir"
        exit 1
    fi
    echo "✓ Directory exists: $dir"
done

# Terraform files
echo ""
echo "Checking Terraform files..."
for file in terraform/{main.tf,variables.tf,terraform.tfvars,outputs.tf,inventory.tpl}; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing file: $file"
        exit 1
    fi
    echo "✓ File exists: $file"
done

# Ansible files
echo ""
echo "Checking Ansible files..."
if [ ! -f "ansible/setup-k8s.yml" ]; then
    echo "❌ Missing file: ansible/setup-k8s.yml"
    exit 1
fi
echo "✓ Ansible playbook found"

# K8s files
echo ""
echo "Checking Kubernetes files..."
for file in k8s/{deployment.yml,service.yml,hpa.yml,kustomization.yaml,deploy.sh}; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing file: $file"
        exit 1
    fi
    echo "✓ File exists: $file"
done

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
cd terraform
terraform init
cd ..
echo "✓ Terraform initialized"

# Summary
echo ""
echo "=========================================="
echo "Setup Completed Successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Set GitHub secrets:"
echo "   - DOCKER_USERNAME"
echo "   - DOCKER_PASSWORD"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - AWS_REGION"
echo "   - EC2_PRIVATE_KEY (content of arman-devops-key)"
echo "   - EC2_PUBLIC_KEY (content of arman-devops-key.pub)"
echo ""
echo "2. Push to master branch to trigger pipeline:"
echo "   git push origin master"
echo ""
echo "3. Monitor deployment:"
echo "   - Check GitHub Actions in your repository"
echo "   - Review logs for any errors"
echo ""
echo "For more details, see KUBERNETES_GUIDE.md"
echo "=========================================="
