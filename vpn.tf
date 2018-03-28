# OpenVPN Access Server
data "aws_ami" "openvpn-access-server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["OpenVPN Access Server *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_instance" "king-vpn" {
  ami = "${data.aws_ami.openvpn-access-server.id}"

  instance_type = "t2.medium"

  key_name = "${var.public_key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.king-vpn.id}",
  ]

  subnet_id = "${module.king-vpc.public_subnets[0]}"

  user_data = <<EOF
admin_user=openvpn
admin_pw=openvpn
EOF

  tags {
    Name = "king-vpn"
  }
}

resource "aws_security_group" "king-vpn" {
  name   = "king-vpn"
  vpc_id = "${module.king-vpc.vpc_id}"
}

resource "aws_security_group_rule" "king-vpn-allow-access-from-all-ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.king-vpn.id}"
}

resource "aws_security_group_rule" "king-vpn-allow-access-from-all-https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.king-vpn.id}"
}

resource "aws_security_group_rule" "king-vpn-allow-access-from-all-openvpn" {
  type        = "ingress"
  from_port   = 1194
  to_port     = 1194
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.king-vpn.id}"
}

resource "aws_security_group_rule" "king-vpn-allow-access-from-all-openvpn-admin" {
  type        = "ingress"
  from_port   = 943
  to_port     = 943
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.king-vpn.id}"
}

resource "aws_security_group_rule" "king-vpn-allow-access-to-all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.king-vpn.id}"
}

# resource "aws_route53_record" "king-vpn" {
#   zone_id = ""
#   name    = ""
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_instance.king_vpc.public_ip}"]
# }

