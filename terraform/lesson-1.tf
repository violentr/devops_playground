# Doc https://www.terraform.io/docs/providers/aws/

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "test_pentest_box" {
  ami = "ami-0e9bfaeb0ca0a0037"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_https.id]
  user_data = file("install.sh")

  tags = {
    Name = "clone pentest box"
    Owner = "Cloud User"
    Project = "Terraform lessons"
  }
}

resource "aws_security_group" "allow_http_https" {
  name        = "HTTP and HTTPS"
  description = "Allow HTTP and HTTPS inbound traffic"

  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTP and HTTPS"
  }
}
