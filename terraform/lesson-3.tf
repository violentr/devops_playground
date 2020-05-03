# Set rules using dynamic block

provider "aws" {
  region = "eu-west-2"
}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "HTTP HTTPS and SSH"
  description = "Allow HTTP HTTPS SSH inbound traffic"

  dynamic "ingress" {
    for_each = ["80", "443", "8080", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HTTP HTTPS and SSH"
  }
}
