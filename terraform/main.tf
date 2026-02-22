provider "aws" {
  region = var.region
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-project-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "devops_key" {
  key_name   = "arman-devops-key"
  public_key = var.public_key
}

resource "aws_instance" "devops_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.devops_key.key_name

  vpc_security_group_ids = [aws_security_group.devops_sg.id]

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
  sleep 40
  ANSIBLE_HOST_KEY_CHECKING=False \
  ansible-playbook -i ../ansible/inventory/hosts.ini ../ansible/setup-k8s.yml -u ec2-user
  EOT
  }
}


