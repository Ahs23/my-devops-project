provider "aws" {
  region = var.region
}

resource "aws_security_group" "devops_sg" {
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

  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "aws_instance" "devops_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  key_name               = aws_key_pair.devops_key.key_name
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -x
              echo "=== Starting user_data script ===" > /var/log/user-data.log
              date >> /var/log/user-data.log
              
              # Update system
              yum update -y 2>&1 | tee -a /var/log/user-data.log
              
              # Install Docker
              yum install -y docker 2>&1 | tee -a /var/log/user-data.log
              
              # Start Docker
              systemctl start docker 2>&1 | tee -a /var/log/user-data.log
              systemctl enable docker 2>&1 | tee -a /var/log/user-data.log
              
              # Ensure ec2-user has proper SSH setup
              echo "=== Verifying ec2-user SSH setup ===" >> /var/log/user-data.log
              mkdir -p /home/ec2-user/.ssh
              chmod 700 /home/ec2-user/.ssh
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh
              
              echo "=== User data script completed ===" >> /var/log/user-data.log
              date >> /var/log/user-data.log
              EOF
  )

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
ls -la "$SSH_KEY"
echo "✓ SSH key permissions set correctly"

# Debug: Check key format
echo "=== SSH Key Info ==="
head -1 "$SSH_KEY"
wc -l "$SSH_KEY"

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
          -v \
          -i "$SSH_KEY" \
          ec2-user@$INSTANCE_IP \
          "echo 'SSH Ready'" 2>&1; then
    echo "✓ SSH connection successful!"
    break
  else
    echo "Connection failed (attempt $attempt/$max_attempts)"
    
    # Debug: try to get instance console output
    if [ $attempt -eq 1 ]; then
      echo "First attempt failed, checking system logs..."
      ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$SSH_KEY" ec2-user@$INSTANCE_IP "tail -20 /var/log/user-data.log" 2>/dev/null || echo "Could not retrieve logs"
    fi
    
    if [ $attempt -lt $max_attempts ]; then
      echo "Waiting 15 seconds before retry..."
      sleep 15
    fi
  fi
done

if [ $attempt -eq $max_attempts ]; then
  echo ""
  echo "ERROR: Could not establish SSH connection after $max_attempts attempts"
  echo ""
  echo "=== DEBUG INFO ==="
  echo "Instance IP: $INSTANCE_IP"
  echo "SSH Key path: $SSH_KEY"
  echo "SSH Key exists: $([ -f $SSH_KEY ] && echo 'YES' || echo 'NO')"
  echo ""
  echo "Manual SSH test command:"
  echo "ssh -v -i $SSH_KEY ec2-user@$INSTANCE_IP"
  echo ""
  echo "Check EC2 console for:"
  echo "1. Instance is in 'running' state"
  echo "2. Public IP is assigned"
  echo "3. Security group allows port 22 inbound"
  echo ""
  exit 1
fi

echo ""
echo "=== SSH Connection Successful! ==="
echo "Ready to run Ansible playbook..."
echo ""

# TODO: Uncomment when SSH is working
# echo "=== Running Ansible playbook ==="
# cd ../ansible
# ANSIBLE_HOST_KEY_CHECKING=False \
# ansible-playbook -i inventory/hosts.ini setup-k8s.yml -u ec2-user -v

echo "Ansible playbook execution is currently DISABLED for debugging."
echo "Re-enable it once SSH connectivity is confirmed."
EOT
  }
}


