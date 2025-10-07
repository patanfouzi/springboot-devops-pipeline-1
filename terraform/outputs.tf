output "app_public_ip" {
  description = "Public IP of the App server"
  value = aws_instance.app.*.public_ip
}

output "mysql_public_ip" {
  description = "Public IP of the Mysql server"
  value = aws_instance.mysql.*.public_ip
}
