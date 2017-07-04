output "ecs" {
  value = "${
    map(
      "sg-ec2", "${aws_security_group.sg-ec2.id}"
    )
  }"
}
