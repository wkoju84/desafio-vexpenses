
# Exporta o ID do Security Group
# Utiliza a variável 'sg_id'
output "sg_id" {
  value = aws_security_group.main_sg.id
}
