output "ec2_public_ip" {
  value = aws_instance.devops.public_ip
}
