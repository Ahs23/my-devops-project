provider "aws" {
  region = var.region
}

data "aws_security_group" "devops_sg" {
  filter {
    name   = "group-name"
    values = ["devops-project-sg"]
  }
}

data "aws_key_pair" "devops_key" {
  key_name = "arman-devops-key"
}

resource "aws_instance" "devops_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.devops_sg.id]
  key_name               = data.aws_key_pair.devops_key.key_name

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


