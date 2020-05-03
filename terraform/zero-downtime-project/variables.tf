variable "region" {
  type = string
  default = "eu-west-2"
}

variable "ports_allowed" {
  type = list
  description = "Allow: Please enter list of ports"
  default = ["80", "443", "8080", "22"]
}

variable "instance_type" {
  type = string
  description = "Please enter your ec2 type"
  default = "t2.micro"
}
