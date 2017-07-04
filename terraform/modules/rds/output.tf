output "rds" {
  value = "${
    map(
      "endpoint", "${aws_rds_cluster.cluster.endpoint}",
      "master_username", "${lookup(var.rds, "${terraform.env}.master_username", var.rds["default.master_username"])}",
      "master_password", "${lookup(var.rds, "${terraform.env}.master_password", var.rds["default.master_password"])}"
    )
  }"
}
