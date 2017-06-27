#
# VPC
#

resource "aws_vpc" "vpc" {
  cidr_block = "${lookup(var.vpc, "${terraform.env}.cidr_block", var.vpc["default.cidr_block"])}"

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  }
}

#
# Internet Gateway
#

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}"
  }
}

#
# Subnets
#

resource "aws_subnet" "public-a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.vpc, "${terraform.env}.public-a", var.vpc["default.public-a"])}"
  availability_zone = "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}a"

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-public-a"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.vpc, "${terraform.env}.public-c", var.vpc["default.public-c"])}"
  availability_zone = "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}c"

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-public-c"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.vpc, "${terraform.env}.private-a", var.vpc["default.private-a"])}"
  availability_zone = "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}a"

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-private-a"
  }
}

resource "aws_subnet" "private-c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.vpc, "${terraform.env}.private-c", var.vpc["default.private-c"])}"
  availability_zone = "${lookup(var.common, "${terraform.env}.region", var.common["default.region"])}c"

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-private-c"
  }
}

#
# Route Tables
#

resource "aws_default_route_table" "public" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${lookup(var.common, "${terraform.env}.project", var.common["default.project"])}-private"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_default_route_table.public.id}"
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = "${aws_subnet.public-c.id}"
  route_table_id = "${aws_default_route_table.public.id}"
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = "${aws_subnet.private-a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-c" {
  subnet_id      = "${aws_subnet.private-c.id}"
  route_table_id = "${aws_route_table.private.id}"
}
