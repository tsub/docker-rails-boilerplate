variable "common" {
  default = {
    default.region  = "ap-northeast-1"
    default.project = "tsub"
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
