#
# Security Group
#

resource "aws_security_group" "sg-rds" {
  name   = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-rds"
  vpc_id = "${var.vpc["vpc_id"]}"

  ingress = {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.ecs["sg-ec2"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-rds"
  }
}

#
# RDS
#

resource "aws_db_subnet_group" "subnet_group" {
  name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"

  subnet_ids = [
    "${var.vpc["subnet-private-a"]}",
    "${var.vpc["subnet-private-c"]}",
  ]
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier        = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  database_name             = "${lookup(var.rds, "${terraform.env}.database_name", var.rds["default.database_name"])}"
  master_username           = "${lookup(var.rds, "${terraform.env}.master_username", var.rds["default.master_username"])}"
  master_password           = "${lookup(var.rds, "${terraform.env}.master_password", var.rds["default.master_password"])}"
  final_snapshot_identifier = true
  port                      = 3306
  apply_immediately         = true
  vpc_security_group_ids    = ["${aws_security_group.sg-rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.subnet_group.name}"

  availability_zones = [
    "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}a",
    "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}c",
  ]
}

resource "aws_rds_cluster_instance" "cluster_instance" {
  cluster_identifier   = "${aws_rds_cluster.cluster.id}"
  identifier           = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-${count.index}"
  instance_class       = "${lookup(var.rds, "${terraform.env}.instance_class", var.rds["default.instance_class"])}"
  db_subnet_group_name = "${aws_db_subnet_group.subnet_group.name}"
  count                = "${lookup(var.rds, "${terraform.env}.count", var.rds["default.count"])}"
}
