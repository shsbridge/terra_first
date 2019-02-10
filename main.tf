provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
   ami = "ami-76144b0a"
   instance_type = "t2.micro"


   tags {
     name = "terraform-example"
   }
}
