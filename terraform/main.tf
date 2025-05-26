############################################
# Provider
############################################
provider "aws" {
  region = "us-east-1"
}

############################################
# VPC
############################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

############################################
# Public subnets (AZ a & AZ b for ALB)
############################################
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

############################################
# Private subnet (EC2)
############################################
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

############################################
# Internet gateway & public route table
############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate both public subnets with the public RT
resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

############################################
# Security groups
############################################
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  ingress { from_port = 80 to_port = 80 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0  to_port = 0  protocol = "-1"   cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

############################################
# EC2 instance (private subnet)
############################################
resource "aws_instance" "nginx" {
  ami                    = "ami-0c2b8ca1dad447f8a"   # Amazon Linux 2 (us-east-1)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-USERDATA
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    docker run -d -p 80:80 nivbadasshboss/custom-nginx:latest
  USERDATA

  tags = { Name = "nginx-private" }
}

############################################
# Application Load Balancer (public)
############################################
resource "aws_lb" "alb" {
  name               = "nginx-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]   # 2 AZs!
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "tg" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

