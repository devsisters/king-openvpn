data "template_file" "king-consul-user-data" {
  template = "${file("files/consul.sh")}"
}

data "aws_iam_policy_document" "ec2_describe_instances" {
  statement {
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "ec2" {
  name_prefix = "king-consul"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2" {
  name = "king-consul"
  role = "${aws_iam_role.ec2.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "ec2-describe-instances" {
  name_prefix = "king-consul"
  description = "policy for king-consul"

  policy = "${data.aws_iam_policy_document.ec2_describe_instances.json}"
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.ec2-describe-instances.arn}"
}

resource "aws_instance" "king-consul" {
  ami           = "${data.aws_ami.ubuntu-xenial.id}"
  instance_type = "t2.micro"
  key_name      = "${var.public_key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.ec2.name}"

  vpc_security_group_ids = [
    "${aws_security_group.king-consul.id}",
  ]

  subnet_id = "${module.king-vpc.public_subnets[1]}"

  count = 3

  user_data = "${data.template_file.king-consul-user-data.rendered}"

  tags {
    Name       = "king-consul-${count.index}"
    ConsulJoin = "v1"
  }
}

resource "aws_security_group" "king-consul" {
  name   = "king-consul"
  vpc_id = "${module.king-vpc.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.king-vpn.id}", "${aws_security_group.king-swan.id}"]
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
