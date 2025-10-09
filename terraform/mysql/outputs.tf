output "mysql_ip" {
  value = aws_instance.mysql.*.public_ip
  description = "Public IP of MySQL server"
}
