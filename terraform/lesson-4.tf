# Use lifecycle, prevent to destroy instance
# https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations

provider "aws" {
  region = "eu-west-2"
}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.test_pentest_box.id
}

resource "aws_instance" "test_pentest_box" {
  ami = "ami-0e9bfaeb0ca0a0037"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]

  user_data = templatefile("install.sh.tpl", {
    f_name = "Cloud user",
    friends = ["Alex", "Robert", "Jasmine", "Sergio", "Diana"]
  })

  tags = {
    Name = "clone pentest box"
    Owner = "Cloud User"
    Project = "Terraform lessons"
  }

  lifecycle {
    # prevent_destroy = true
    # ignore_changes = [ami, user_data]
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_http_https_ssh" {
  name        = "HTTP HTTPS and SSH"
  description = "Allow HTTP HTTPS and SSH inbound traffic"

  dynamic "ingress" {
    for_each = ["80", "443", "22"]

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
