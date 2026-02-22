provider "aws" {
  region = var.region
}

data "aws_security_group" "devops_sg" {
  filter {
    name   = "group-name"
    values = ["devops-project-sg"]
  }
}

resource "aws_key_pair" "devops_key" {
  key_name   = "arman-devops-key"
  public_key = var.public_key
}

resource "aws_instance" "devops_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.devops_sg.id]
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
echo "Waiting for SSH to be ready..."
for i in {1..30}; do
  if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/arman-devops-key ec2-user@${aws_instance.devops_server.public_ip} "echo 'SSH Ready'" 2>/dev/null; then
    echo "SSH connection successful!"
    break
  fi
  echo "Attempt $i: Waiting for SSH..."
  sleep 10
done

echo "Running Ansible playbook..."
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i ../ansible/inventory/hosts.ini ../ansible/setup-k8s.yml -u ec2-user
EOT
  }
}


