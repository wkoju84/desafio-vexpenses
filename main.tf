module "vpc" {
  source = "./modules/vpc"

  projeto   = var.projeto
  candidato = var.candidato
}

module "security" {
  source = "./modules/security"

  projeto   = var.projeto
  candidato = var.candidato
  vpc_id    = module.vpc.vpc_id
}

module "ec2" {
  source      = "./modules/ec2"
  projeto     = var.projeto
  candidato   = var.candidato
  subnet_id   = module.vpc.main_subnet
  sg_id       = module.security.sg_id
}

