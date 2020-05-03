/*
Create:
  - Security Group for Web server
  - Launch configuration with auto AMI lookup
https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  - Auto scaling group using availability zones
https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
  - Classic load balancer in availability zones
https://www.terraform.io/docs/providers/aws/r/lb.html
*/

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" { }

data "aws_ami" "latest_amazon_linux" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

/* Security Group */

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "HTTP HTTPS and SSH"
  description = "Allow HTTP HTTPS and SSH inbound traffic"

  dynamic "ingress" {
    for_each = var.ports_allowed
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

resource "aws_launch_configuration" "web" {
  /* cant use name attr, should be uniq, name_prefix used instead  */
  name_prefix = "WebServer-highly-available-LC-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.allow_ssh_http_https.id]
  user_data = file("install.sh")

  lifecycle {
    create_before_destroy = true
  }
}

/* Autoscaling group */

resource "aws_autoscaling_group" "web" {
  name = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size = 2
  max_size = 2
  min_elb_capacity = 2
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  health_check_type = "ELB"
  load_balancers = [aws_elb.web.name]

  dynamic "tag" {
    for_each  = {
      Name = "WebServer in ASG"
      Owner = "Other cloud user"
      TAGKEY = "TAGVALUE"

    }
    content {
       key = tag.key
       value = tag.value
       propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

/* Create Load balancer */

resource "aws_elb" "web" {
  name = "WebServer-High-availability-LB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups = [aws_security_group.allow_ssh_http_https.id]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_protocol = "http"
    instance_port = 80
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }
  tags = {
      Name = "WebServer High available ELB"
  }
}

/* resource default subnet */

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}


output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}
