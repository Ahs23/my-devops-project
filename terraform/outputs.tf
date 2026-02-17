output "instance public ip" {
  description = "Public IP of the EC2 instance"
  value = aws_instance.devops_server.public_ip
}