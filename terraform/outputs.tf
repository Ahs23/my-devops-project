output "instance_public ip" {
  description = "Public IP of the EC2 instance"
  value = aws_instance.devops_server.public_ip
}

output "ssh_connection_command" {
  description = "SSH command to connect to EC2 instance"
  value = "ssh ec2-user@${aws_instance.devops_server.public_ip}"  
  
}