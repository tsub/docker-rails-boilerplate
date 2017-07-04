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
  rds    = "${module.rds.rds}"
}

module "rds" {
  source = "modules/rds"
  common = "${var.common}"
  rds    = "${var.rds}"
  vpc    = "${module.vpc.vpc}"
  ecs    = "${module.ecs.ecs}"
}
