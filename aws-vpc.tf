provider "aws" {
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "iamodion"
    key    = "project/terraform.tfstate"
    region = "us-east-1"
  }
}


resource "aws_vpc" "project" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My-project VPC"
  }
}

resource "aws_subnet" "subnetpub" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "project-public-subnet"
  }
}

resource "aws_subnet" "subnetpriv" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "project-private-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.project.id

  tags = {
    Name = "Project-gateway"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "project-route"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnetpub.id
  route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnetpriv.id
  route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "project-SG" {
  name        = "Project-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.project.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Project-SG"
  }
}
