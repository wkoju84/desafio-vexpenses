# Configura o backend para armazenar o estado no S3
# Nome do bucket, chave e região especificados.
terraform {
  backend "s3" {
    bucket = "vexpenses-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}