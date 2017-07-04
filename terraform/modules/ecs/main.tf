#
# AMI
#

data "aws_ami" "ecs-optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

#
# User Data
#

data "template_file" "script" {
  template = "${file("${path.module}/templates/user_data/script.sh.tpl")}"

  vars {
    cluster = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  }
}

data "template_cloudinit_config" "user-data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.script.rendered}"
  }
}

#
# Security Group
#

resource "aws_security_group" "sg-ec2" {
  name   = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-ec2"
  vpc_id = "${var.vpc["vpc_id"]}"

  ingress = {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg-alb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-ec2"
  }
}

resource "aws_security_group" "sg-alb" {
  name   = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-alb"
  vpc_id = "${var.vpc["vpc_id"]}"

  ingress = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-alb"
  }
}

#
# IAM Role
#

data "aws_iam_policy_document" "document-ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "document-ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role-ec2" {
  name               = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-ec2"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.document-ec2.json}"
}

resource "aws_iam_role" "role-ecs" {
  name               = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-ecs"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.document-ecs.json}"
}

resource "aws_iam_role_policy_attachment" "attachment-ec2" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = "${aws_iam_role.role-ec2.id}"
}

resource "aws_iam_role_policy_attachment" "attachment-ecs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = "${aws_iam_role.role-ecs.id}"
}

resource "aws_iam_instance_profile" "profile" {
  name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-ec2"
  role = "${aws_iam_role.role-ec2.name}"
}

#
# Launch Configration
#

resource "aws_launch_configuration" "launch-config" {
  name_prefix                 = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-"
  image_id                    = "${data.aws_ami.ecs-optimized.id}"
  instance_type               = "${lookup(var.ecs, "${terraform.env}.instance_type", var.ecs["default.instance_type"])}"
  iam_instance_profile        = "${aws_iam_instance_profile.profile.id}"
  security_groups             = ["${aws_security_group.sg-ec2.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_cloudinit_config.user-data.rendered}"

  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_size = "${lookup(var.ecs, "${terraform.env}.ebs_volume_size", var.ecs["default.ebs_volume_size"])}"
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Autoscaling Group
#

resource "aws_autoscaling_group" "asg" {
  name                 = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  launch_configuration = "${aws_launch_configuration.launch-config.name}"
  desired_capacity     = "${lookup(var.ecs, "${terraform.env}.desired_capacity", var.ecs["default.desired_capacity"])}"
  min_size             = "${lookup(var.ecs, "${terraform.env}.min_size", var.ecs["default.min_size"])}"
  max_size             = "${lookup(var.ecs, "${terraform.env}.max_size", var.ecs["default.max_size"])}"
  vpc_zone_identifier  = ["${var.vpc["subnet-private-a"]}", "${var.vpc["subnet-private-c"]}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
    propagate_at_launch = true
  }
}

#
# Cloudwatch Logs
#

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/app/${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
}

#
# ECS Cluster
#

resource "aws_ecs_cluster" "ecs" {
  name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
}

#
# ECS Task Definition
#

data "template_file" "app" {
  template = "${file("${path.module}/templates/task_definitions/app.json.tpl")}"

  vars {
    cluster           = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
    region            = "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}"
    rails_master_key  = "${lookup(var.ecs, "${terraform.env}.rails_master_key", var.ecs["default.rails_master_key"])}"
    database_host     = "${var.rds["endpoint"]}"
    database_username = "${var.rds["master_username"]}"
    database_password = "${var.rds["master_password"]}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-app"
  container_definitions = "${data.template_file.app.rendered}"
}

#
# Application Load Balancer
#

resource "aws_alb" "alb" {
  name            = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  security_groups = ["${aws_security_group.sg-alb.id}"]

  subnets = [
    "${var.vpc["subnet-public-a"]}",
    "${var.vpc["subnet-public-c"]}",
  ]

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  }
}

resource "aws_alb_target_group" "target_group" {
  name     = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc["vpc_id"]}"
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.target_group.arn}"
    type             = "forward"
  }
}

#
# ECS Service
#

resource "aws_ecs_service" "app" {
  name            = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-app"
  cluster         = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "${lookup(var.ecs, "${terraform.env}. desired_count", var.ecs["default.desired_count"])}"
  iam_role        = "${aws_iam_role.role-ecs.arn}"

  load_balancer {
    container_name   = "app"
    container_port   = 3000
    target_group_arn = "${aws_alb_target_group.target_group.arn}"
  }
}
