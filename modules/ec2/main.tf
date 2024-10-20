
# Gera uma chave privada RSA com 2048 bits.
# Usada para comunicação segura via TLS/SSH, como acesso a instâncias EC2.
# O algoritmo RSA oferece criptografia forte, com 2048 bits sendo o mínimo recomendado para segurança.
# A chave pública gerada pode ser referenciada em outros recursos, como pares de chave EC2.
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Cria um par de chaves EC2 usando a chave pública gerada.
# Atributo key_name usa variáveis do projeto e candidato.
# A chave pública é obtida do recurso tls_private_key.
# Utilizado para acesso SSH seguro a instâncias EC2.
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.projeto}-${var.candidato}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Obtém a AMI mais recente do Debian 12.
# Filtra por nome e tipo de virtualização HVM.
# A AMI é fornecida pelo proprietário oficial (ID 679593333241).
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

# Cria instância EC2 Debian usando AMI mais recente.
# Tipo t2.micro, em subnet e SG especificados.
# Usa par de chaves gerado para acesso SSH.
# Associa IP público e configura volume de 20GB.
# User Data instala e inicia Nginx.
# Instância recebe tags com nome do projeto e candidato.
resource "aws_instance" "debian_ec2" {
  ami             = data.aws_ami.debian12.id
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_id
  security_groups = [var.sg_id]
  key_name        = aws_key_pair.ec2_key_pair.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Configuração de inicialização da instância (User Data)
  user_data = <<-EOF
              #!/bin/bash
              # Atualizar pacotes
              apt-get update -y
              
              # Instalar Nginx
              apt-get install -y nginx
              
              # Iniciar o serviço Nginx
              systemctl start nginx
              
              # Habilitar Nginx para iniciar automaticamente ao boot
              systemctl enable nginx
              EOF


  tags = {
    Name = "${var.projeto}-${var.candidato}-ec2"
  }
}



