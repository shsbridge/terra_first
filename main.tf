provider "aws" {
  region = "ap-southeast-1"
}
resource "aws_autoscaling_group" "example"{
   launch_configuration = "${aws_launch_configuration.example.id}"
   availability_zones = ["${data.aws_availability_zones.all.names}"]
   min_size = 2
   max_size = 4

   tag {
     key       = "Name"
     value     = "Terraform-ASG-example"
     propagate_at_launch = ture
   }
}
resource "aws_launch_configuration" "example" {
   ami = "ami-0c5199d385b432989"
   instance_type = "t2.micro"
   vpc_security_group_ids = ["${aws_security_group.instance.id}"]
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
variable "http_port" {
  description = "This is http service port"
  default = 8080
}
output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
data "aws_availability_zones" "all" {}
