#
# VPC
#

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc["default.cidr_block"]}"

  tags {
    Name = "${var.common["default.project"]}"
  }
}

#
# Internet Gateway
#

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.common["default.project"]}"
  }
}

#
# Subnets
#

resource "aws_subnet" "public-a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["default.public-a"]}"
  availability_zone = "${var.common["default.region"]}a"

  tags {
    Name = "${var.common["default.project"]}-public-a"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["default.public-c"]}"
  availability_zone = "${var.common["default.region"]}c"

  tags {
    Name = "${var.common["default.project"]}-public-c"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["default.private-a"]}"
  availability_zone = "${var.common["default.region"]}a"

  tags {
    Name = "${var.common["default.project"]}-private-a"
  }
}

resource "aws_subnet" "private-c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc["default.private-c"]}"
  availability_zone = "${var.common["default.region"]}c"

  tags {
    Name = "${var.common["default.project"]}-private-c"
  }
}

#
# Route Tables
#

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.common["default.project"]}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.common["default.project"]}-private"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = "${aws_subnet.public-c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = "${aws_subnet.private-a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-c" {
  subnet_id      = "${aws_subnet.private-c.id}"
  route_table_id = "${aws_route_table.private.id}"
}
