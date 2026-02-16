provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "devops_server" {
  ami           = "ami-0f5ee92e2d63afc18" # Amazon Linux 2 (example)
  instance_type = "t2.micro"

  tags = {
    Name = "devops-project-server"
  }
}
