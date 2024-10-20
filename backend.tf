terraform {
  backend "s3" {
    bucket = "vexpenses-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}