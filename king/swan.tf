data "template_file" "king_swan_user_data" {
  template = "${file("../files/swan.sh")}"

  vars = {
    king_consul_private_ip = "${aws_instance.king_consul.0.private_ip}"
  }
}

# TODO: Setup consul address in user_data
resource "aws_instance" "king_swan" {
  ami = "${data.aws_ami.ubuntu_xenial.id}"

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "${aws_security_group.king_swan.id}",
  ]

  # TODO: 개선할 수 있을지 확인 필요
  subnet_id         = "${module.king_vpc.public_common_subnet_id}"
  source_dest_check = "false"

  key_name = "${var.public_key_name}"

  user_data = "${data.template_file.king_swan_user_data.rendered}"

  tags {
    Name = "king-swan"
  }
}

resource "aws_security_group" "king_swan" {
  name   = "king-swan"
  vpc_id = "${module.king_vpc.vpc_id}"
}

resource "aws_security_group_rule" "king_swan_allow_access_from_all" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.king_swan.id}"
}

resource "aws_security_group_rule" "king_swan_allow_access_to_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.king_swan.id}"
}
