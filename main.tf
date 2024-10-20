
# Chama um módulo para criar a VPC
# Passa as variáveis 'projeto' e 'candidato'.
module "vpc" {
  source = "./modules/vpc"

  projeto   = var.projeto
  candidato = var.candidato
}

# Chama um módulo para configurar a segurança
# Passa as variáveis 'projeto', 'candidato' e o ID da VPC.
module "security" {
  source = "./modules/security"

  projeto   = var.projeto
  candidato = var.candidato
  vpc_id    = module.vpc.vpc_id
}

# Chama um módulo para configurar uma instância EC2
# Passa as variáveis 'projeto', 'candidato', ID da subnet e ID do Security Group.
module "ec2" {
  source      = "./modules/ec2"
  projeto     = var.projeto
  candidato   = var.candidato
  subnet_id   = module.vpc.main_subnet
  sg_id       = module.security.sg_id
}

