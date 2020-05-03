# Use order what to deploy first, depends_on
# https://www.terraform.io/docs/configuration/resources.html

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "db_pentest_box" {
  ami = "ami-0e9bfaeb0ca0a0037"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]

  tags = {
    Name = "Database: clone pentest box"
    Owner = "Cloud User"
    Project = "Terraform lessons"
  }

}

resource "aws_instance" "web_server_pentest_box" {
  ami = "ami-0e9bfaeb0ca0a0037"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]

  user_data = templatefile("install.sh.tpl", {
    f_name = "Cloud user",
    friends = ["Alex", "Robert", "Jasmine", "Sergio", "Diana"]
  })

  tags = {
    Name = "WebServer: clone pentest box"
    Owner = "Cloud User"
    Project = "Terraform lessons"
  }

  depends_on = [aws_instance.db_pentest_box, aws_instance.app_server_pentest_box]
}

resource "aws_instance" "app_server_pentest_box" {
  ami = "ami-0e9bfaeb0ca0a0037"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]

  tags = {
    Name = "AppServer: pentest box"
    Owner = "Cloud User"
    Project = "Terraform lessons"
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

/* output works as return statement */

output "webserver_instance_id" {
  value = aws_instance.web_server_pentest_box.id
}

output "security_group" {
 value = aws_security_group.allow_http_https_ssh.name
}
