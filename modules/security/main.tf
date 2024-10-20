
# Cria um Security Group chamado 'main_sg'
# Nome baseado nas variáveis 'projeto' e 'candidato'
# Descrição: Permitir SSH restrito e todo tráfego de saída
resource "aws_security_group" "main_sg" {
  name        = "${var.projeto}-${var.candidato}-sg"
  description = "Permitir acesso SSH restrito por ip de origem e todo o trafego de saida"
  vpc_id      = var.vpc_id

  # Permite acesso SSH do meu IP
  ingress {
    description      = "Allow SSH from my IP"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["189.78.50.40/32"]

  }
  # Permite acesso HTTP do meu IP
  ingress {
    description      = "Allow HTTP from my IP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["189.78.50.40/32"]

  }

  # Permite todo tráfego de saída
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  # Tags com nome baseado em 'projeto' e 'candidato'
  tags = {
    Name = "${var.projeto}-${var.candidato}-sg"
  }
}

