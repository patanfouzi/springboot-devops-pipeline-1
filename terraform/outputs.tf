output "app_public_ip" {
  value = aws_instance.app.*.public_ip
}

output "mysql_public_ip" {
  value = aws_instance.mysql.*.public_ip
}
