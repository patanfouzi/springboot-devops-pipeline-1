provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "mysql" {
  ami           = data.aws_ami.ubuntu.id 
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "mysql-server"
  }

  security_groups = [aws_security_group.mysql_sg.name]
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "Allow MySQL inbound"
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For demo only; limit in production
  }
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
