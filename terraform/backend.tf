terraform {
  backend "s3" {
    bucket = "tsub-tfstate"
    key    = "docker-rails-boilerplate/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
