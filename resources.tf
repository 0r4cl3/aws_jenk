resource "aws_vpc" "Terraform-VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  disable_api_termination = true
  enable_dns_hostnames = true
  tags = {
    Name = "TERRAFORM-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.Terraform-VPC.id}"
  tags = {
    Name = "TF-IGW"
  }
}

resource "aws_route_table" "route-table-for-public-subnet" {
  vpc_id = "${aws_vpc.Terraform-VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.Terraform-VPC.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "PRIVATE-SUBNET"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.Terraform-VPC.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PUBLIC-SUBNET"
  }
}

resource "aws_route_table_association" "igw-public-subnet-association" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.route-table-for-public-subnet.id}"
}

resource "aws_security_group" "test-group" {
  vpc_id = "${aws_vpc.Terraform-VPC.id}"
  name = "test-group"
  description = "Security Group to test connectivity"

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG Testing Group"
  }
}

resource "aws_instance" "private-instance" {
  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }
  ami = "ami-0ff27f59446639141"
  instance_type = "t2.micro"
  key_name = "GPC"
  vpc_security_group_ids = ["${aws_security_group.test-group.id}"]
  subnet_id = "${aws_subnet.private-subnet.id}"
}

resource "aws_instance" "public-instance" {
  root_block_device {
    volume_size = 15
    volume_type = "gp2"
  }
  ami = "ami-0ff27f59446639141"
  instance_type = "t2.micro"
  key_name = "GPC"
  vpc_security_group_ids = ["${aws_security_group.test-group.id}"]
  subnet_id = "${aws_subnet.public-subnet.id}"
}
