# Use data sources, find and select latest ubuntu
# https://www.terraform.io/docs/providers/aws/d/ami.html

provider "aws" {
  region = "eu-west-2"
}

data "aws_ami" "latest_ubuntu" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

output "latest_ubuntu_server_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}

output "latest_ubuntu_server_ami_name" {
  value = data.aws_ami.latest_ubuntu.name
}
