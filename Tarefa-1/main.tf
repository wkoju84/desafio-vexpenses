
# Define o provedor AWS
# Região especificada: us-east-1 (Norte da Virgínia).
provider "aws" {
  region = "us-east-1" 
}

# Define a variável para o nome do projeto
# Tipo string, valor padrão "VExpenses".
variable "projeto" {
  description = "Nome do projeto"
  type        = string
  default     = "VExpenses"
}

# Define a variável para o nome do candidato
# Tipo string, valor padrão "SeuNome".
variable "candidato" {
  description = "Nome do candidato"
  type        = string
  default     = "SeuNome"
}

# Gera uma chave privada TLS para EC2
# Algoritmo RSA, 2048 bits.
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"  # tipo de arquivo usado na geração da chave privada
  rsa_bits  = 2048
}

# Cria um par de chaves EC2
# Nome baseado nas variáveis 'projeto' e 'candidato'
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.projeto}-${var.candidato}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Cria uma VPC chamada 'main_vpc'
# CIDR: 10.0.0.0/16, DNS e hostnames habilitados.
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-vpc"
  }
}

# Cria uma Subnet chamada 'main_subnet'
# VPC ID associado, CIDR: 10.0.1.0/24, Zona de Disponibilidade: us-east-1a.
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-subnet"
  }
}

# Cria um Internet Gateway chamado 'main_igw'
# VPC ID associado, sem valor padrão.
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-igw"
  }
}

# Cria uma Route Table chamada 'main_route_table'
# VPC ID associado, rota padrão para Internet Gateway.
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  # Define rota padrão para o Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }


  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-route_table"
  }
}

# Associa uma subnet à Route Table
# Subnet ID e Route Table ID associados.
resource "aws_route_table_association" "main_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id


  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-route_table_association"
  }
}


# Cria um Security Group chamado 'main_sg'
# Nome baseado nas variáveis 'projeto' e 'candidato'
resource "aws_security_group" "main_sg" {
  name        = "${var.projeto}-${var.candidato}-sg"
  description = "Permitir SSH de qualquer lugar e todo o tráfego de saída"
  vpc_id      = aws_vpc.main_vpc.id

  # Regras de entrada
  ingress {
    description      = "Allow SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Regras de saída
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-sg"
  }
}

# Busca a AMI mais recente do Debian 12
# Filtros aplicados: nome e tipo de virtualização
data "aws_ami" "debian12" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

# Cria uma instância EC2 com Debian
# AMI, tipo, subnet, chave, e grupos de segurança especificados.
resource "aws_instance" "debian_ec2" {
  ami             = data.aws_ami.debian12.id 
  instance_type   = "t2.micro" 
  subnet_id       = aws_subnet.main_subnet.id
  key_name        = aws_key_pair.ec2_key_pair.key_name
  security_groups = [aws_security_group.main_sg.name]

  associate_public_ip_address = true

  # Configuração do dispositivo root
  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Script de inicialização (user data)
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              EOF

  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-ec2" 
  }
}

# Exporta a chave privada para acessar a instância EC2
# Sensível, para segurança.
output "private_key" {
  description = "Chave privada para acessar a instância EC2"
  value       = tls_private_key.ec2_key.private_key_pem
  sensitive   = true
}

# Exporta o endereço IP público da instância EC2
# Utiliza a variável 'ec2_public_ip'
output "ec2_public_ip" {
  description = "Endereço IP público da instância EC2"
  value       = aws_instance.debian_ec2.public_ip
}
