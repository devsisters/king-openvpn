output "king_vpn_private_ip" {
  value = "${aws_instance.king_vpn.private_ip}"
}

output "king_swan_public_ip" {
  value = "${aws_instance.king_swan.public_ip}"
}

output "king_swan_private_ip" {
  value = "${aws_instance.king_swan.private_ip}"
}

output "king_swan_sg_id" {
  value = "${aws_security_group.king_swan.id}"
}

output "king_swan_network_interface_id" {
  value = "${aws_instance.king_swan.network_interface_id}"
}
