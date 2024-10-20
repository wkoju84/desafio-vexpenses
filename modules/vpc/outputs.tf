
# Exporta o ID da VPC
# Utiliza a variável 'vpc_id'
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

# Exporta o ID da Subnet
# Utiliza a variável 'main_subnet'
output "main_subnet" {
  value = aws_subnet.main_subnet.id
}

# Exporta o ID do Internet Gateway
# Utiliza a variável 'aws_internet_gateway'
output "aws_internet_gateway" {
  value = aws_internet_gateway.main_igw.id
}

# Exporta o CIDR Block da Subnet
# Utiliza a variável 'cidr_block'
output "cidr_block" {
  value = aws_subnet.main_subnet.cidr_block
}