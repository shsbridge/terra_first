provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
   ami = "ami-0c5199d385b432989"
   instance_type = "t2.micro"
   vpc_security_group_ids = ["${aws_security_group.instance.id}"]
   key_name = "EffectiveDevOpsAWS"
   user_data = <<-EOF
               #!/bin/bash
               echo "Hello, World, This is a test webpage" > index.html
               nohup busybox httpd -f -p 8080 &
               EOF
  
   tags {
     Name = "terraform-example"
   }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress{
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["121.7.188.193/32"]
  }
}
