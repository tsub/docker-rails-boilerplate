module "vpc" {
  source = "modules/vpc"
  common = "${var.common}"
  vpc    = "${var.vpc}"
}

module "ecs" {
  source = "modules/ecs"
  common = "${var.common}"
  ecs    = "${var.ecs}"
  vpc    = "${module.vpc.vpc}"
}
