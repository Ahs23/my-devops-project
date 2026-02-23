[devops_server]
ec2-instance ansible_host=${public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./arman-devops-key ansible_ssh_common_args='-o StrictHostKeyChecking=no'