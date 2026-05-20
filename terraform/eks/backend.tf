terraform {
  backend "s3" {
    bucket         = "seglianik-hw28-tf-state-119778517941"
    key            = "eks/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "seglianik-hw28-tf-lock"
  }
}

