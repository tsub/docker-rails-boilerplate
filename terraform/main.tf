module "vpc" {
  source = "modules/vpc"
  common = "${var.common}"
  vpc    = "${var.vpc}"
}
