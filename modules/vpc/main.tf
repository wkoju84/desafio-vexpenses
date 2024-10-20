
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
}
