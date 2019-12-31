provider "aws" {
  region     = "us-west-1"
  access_key = "access"
  secret_key = "secrete"
}
resource "aws_vpc" "mainvcp" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name ="myvcp"
    Location = "USA"
  }
  
}
resource "aws_subnet" "sub1" {
  vpc_id     = "${aws_vpc.mainvcp.id}"
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "subvcp"
  }

} 
resource "aws_instance" "instance1" {
  ami           = "ami-0b2d8d1abb76a53d8" # us-west-2
  instance_type = "t2.micro"
  tags = {
    Name = "terra-ec2"
  }
}
resource "aws_s3_bucket" "terrabucket" {
  bucket = "terrabuckettftest"
  acl    = "private"
  tags = {
    Name = "bucket-terra"
 }
}

//ecr-creating script//
provider "aws" {
  region     = "us-west-1"
}
resource "aws_ecr_repository" "terraecr" {
  name                 = "ecr-terra"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

//elb-creating script//
provider "aws" {
  region     = "us-west-1"
}
resource "aws_instance" "instance1" {
  ami           = "ami-0b2d8d1abb76a53d8" # us-west-2
  instance_type = "t2.micro"
}
resource "aws_elb" "bar" {
  name               = "tera-elb"
  availability_zones = ["us-west-1c", "us-west-1b"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances                   = ["${aws_instance.instance1.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = "my-elb"
  }
}
