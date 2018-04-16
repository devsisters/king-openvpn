resource "aws_security_group" "king-swan-client" {
  name   = "king-swan-client"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.terraform_remote_state.king_vpn.private_ip}/32"]
  }
}

resource "aws_security_group_rule" "king-swan" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${aws_vpn_connection.king-swan.tunnel1_address}/32"]
  security_group_id = "${data.terraform_remote_state.king_vpn.sg_id}"
}
