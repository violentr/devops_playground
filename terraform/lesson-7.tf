# Use data sources
# https://www.terraform.io/docs/providers/aws/d/instance.html

provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/* select the instance */

data "aws_instance" "current" {
  instance_tags = {
    Name = "Ubuntu-playground/Pentest-box"
  }
}

output "data_aws_current_ec2_state" {
  value = data.aws_instance.current.instance_state
}

output "data_aws_current_ec2_ami" {
  value = data.aws_instance.current.ami
}

output "data_aws_current_region" {
  value = data.aws_region.current.name
}

output "data_aws_current_region_description" {
  value = data.aws_region.current.description
}


output "data_aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}

output "data_aws_availability_zone" {
  value = data.aws_availability_zones.working.names[2]
  description = "Select element from array of elements"
}


output "data_aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
}
