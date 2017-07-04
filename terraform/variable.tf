variable "common" {
  default = {
    default.region  = "ap-northeast-1"
    default.project = "tsub"

    sandbox.region  = "ap-northeast-1"
    sandbox.project = "sandbox-tsub"
  }
}

variable "vpc" {
  default = {
    default.cidr_block = "10.0.0.0/16"
    default.public-a   = "10.0.0.0/24"
    default.public-c   = "10.0.1.0/24"
    default.private-a  = "10.0.2.0/24"
    default.private-c  = "10.0.3.0/24"
  }
}

variable "ecs" {
  default = {
    default.instance_type    = "t2.micro"
    default.ebs_volume_size  = 100
    default.desired_capacity = 1
    default.min_size         = 1
    default.max_size         = 1
    default.desired_count    = 2
    default.rails_master_key = ""

    sandbox.instance_type    = "t2.micro"
    sandbox.ebs_volume_size  = 100
    sandbox.desired_capacity = 1
    sandbox.min_size         = 1
    sandbox.max_size         = 1
    sandbox.desired_count    = 2
    default.rails_master_key = ""
  }
}

variable "rds" {
  default = {
    default.instance_class  = "db.t2.small"
    default.database_name   = "docker_rails_boilerplate_development"
    default.master_username = ""
    default.master_password = ""
    default.count           = 2

    sandbox.instance_class  = "db.t2.small"
    sandbox.database_name   = "docker_rails_boilerplate_development"
    sandbox.master_username = ""
    sandbox.master_password = ""
    sandbox.count           = 2
  }
}
