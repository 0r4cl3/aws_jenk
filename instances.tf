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
