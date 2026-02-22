variable "region" {
  description = "AWS region for deployment"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance size"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0f5ee92e2d63afc18"
}

variable "public_key" {
  description = "SSH Public key"
}