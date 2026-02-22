provider "aws" {
  region = var.region
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-project-sg"
  description = "Security group for DevOps CI/CD"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "devops-project-sg"
  }
}

resource "aws_key_pair" "devops_key" {
  key_name   = "arman-devops-key"
  public_key = var.public_key
}

resource "aws_instance" "devops_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  key_name               = aws_key_pair.devops_key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "devops-project-server"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    public_ip = aws_instance.devops_server.public_ip
  })

  filename = "../ansible/inventory/hosts.ini"
}

resource "null_resource" "run_ansible" {
  depends_on = [aws_instance.devops_server, local_file.ansible_inventory]

  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash
set -e

INSTANCE_IP="${aws_instance.devops_server.public_ip}"
SSH_KEY="$HOME/.ssh/arman-devops-key"

echo "=== Waiting for EC2 instance to be ready ==="
echo "Instance IP: $INSTANCE_IP"
echo "SSH Key: $SSH_KEY"

# Verify key exists
if [ ! -f "$SSH_KEY" ]; then
  echo "ERROR: SSH key file not found at $SSH_KEY"
  exit 1
fi

chmod 600 "$SSH_KEY"
echo "✓ SSH key permissions set correctly"

# Initial wait for EC2 to fully boot and run user_data
echo "Waiting 300 seconds (5 minutes) for EC2 instance to fully boot and initialize..."
sleep 300

echo "Attempting SSH connection (max 50 attempts)..."
max_attempts=50
attempt=0

while [ $attempt -lt $max_attempts ]; do
  attempt=$((attempt + 1))
  echo "[$attempt/$max_attempts] Testing SSH connection to ec2-user@$INSTANCE_IP..."
  
  if ssh -o ConnectTimeout=10 \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -o PasswordAuthentication=no \
          -i "$SSH_KEY" \
          ec2-user@$INSTANCE_IP \
          "echo 'SSH Ready'" 2>&1; then
    echo "✓ SSH connection successful!"
    break
  else
    echo "Connection failed (attempt $attempt/$max_attempts)"
    if [ $attempt -lt $max_attempts ]; then
      echo "Waiting 15 seconds before retry..."
      sleep 15
    fi
  fi
done

if [ $attempt -eq $max_attempts ]; then
  echo "ERROR: Could not establish SSH connection after $max_attempts attempts"
  echo "Debugging info:"
  echo "Instance IP: $INSTANCE_IP"
  echo "SSH Key exists: $([ -f $SSH_KEY ] && echo 'YES' || echo 'NO')"
  echo "Try manual SSH test: ssh -i $SSH_KEY ec2-user@$INSTANCE_IP"
  exit 1
fi

echo "=== Running Ansible playbook ==="
cd ../ansible
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventory/hosts.ini setup-k8s.yml -u ec2-user -v
EOT
  }
}


