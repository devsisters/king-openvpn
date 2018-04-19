resource "aws_security_group" "king_swan_client" {
  name   = "king-swan-client"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.terraform_remote_state.king_vpn.king_vpn_private_ip}/32"]
  }
}

resource "aws_security_group_rule" "king_swan" {
  provider = "aws.tokyo"

  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${aws_vpn_connection.king_swan.tunnel1_address}/32"]
  security_group_id = "${data.terraform_remote_state.king_vpn.king_swan_sg_id}"
}
