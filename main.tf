provider "aws" {
  region = "ap-southeast-1"
}
resource "aws_elb" "example" {
   name            = "terraform-asg-example"
   availability_zones = ["${data.aws_availability_zones.all.names}"]
   security_groups  = ["${aws_security_group.elb.id}"]
   
   listener {
     lb_port   = 80
     lb_protocol = "http"
     instance_port = "${var.http_port}"
     instance_protocol = "http"
   }
   
   health_check {
     healthy_threshold  = 2
     unhealthy_threshold  = 2
     timeout    = 3
     interval   = 30
     target     = "HTTP:${var.http_port}/"
   }
}
resource "aws_autoscaling_group" "example" {
   launch_configuration = "${aws_launch_configuration.example.id}"
   availability_zones = ["${data.aws_availability_zones.all.names}"]

   load_balancers   = ["${aws_elb.example.name}"]
   health_check_type  = "ELB"

   min_size = 2
   max_size = 4

   tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
resource "aws_launch_configuration" "example" {
   image_id  = "ami-0c5199d385b432989"
   instance_type = "t2.micro"
   security_groups = ["${aws_security_group.instance.id}"]
   key_name = "EffectiveDevOpsAWS"
   user_data = <<-EOF
               #!/bin/bash
               echo "Hello, World, This is a test webpage" > index.html
               nohup busybox httpd -f -p "${var.http_port}" &
               EOF
   lifecycle {
     create_before_destroy = true
   } 
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress{
    from_port = "${var.http_port}"
    to_port   = "${var.http_port}"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["121.7.188.192/32"]
  }
  lifecycle {
    create_before_destroy = true
  } 
}
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
variable "http_port" {
  description = "This is http service port"
  default = 8080
}
data "aws_availability_zones" "all" {}
output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}
