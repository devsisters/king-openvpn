# Ubuntu Server 16.04 LTS (HVM)
data "aws_ami" "ubuntu-xenial" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "king-swan-user-data" {
  template = "${file("files/swan.sh")}"
}

# TODO: Setup consul address in user_data
resource "aws_instance" "king-swan" {
  ami = "${data.aws_ami.ubuntu-xenial.id}"

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "${aws_security_group.allow-access-from-all.id}",
  ]

  # TODO: 개선할 수 있을지 확인 필요
  subnet_id         = "${module.king-vpc.public_subnets[0]}"
  source_dest_check = "false"

  key_name = "${var.public_key_name}"

  user_data = "${data.template_file.king-swan-user-data.rendered}"

  tags {
    Name = "king-swan"
  }
}

resource "aws_security_group" "allow-access-from-all" {
  name   = "king-swan"
  vpc_id = "${module.king-vpc.vpc_id}"
}

resource "aws_security_group_rule" "allow-access-from-all" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow-access-from-all.id}"
}

resource "aws_security_group_rule" "allow-access-to-all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow-access-from-all.id}"
}
