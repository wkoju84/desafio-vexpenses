# Exibe o IP público da instância EC2 criada.
# Útil para acesso via SSH ou HTTP.
output "ec2_public_ip" {
  description = "Public IP EC2"
  value       = aws_instance.debian_ec2.public_ip
}

# Exibe a chave privada SSH gerada (formato PEM).
# Marcada como sensível para ocultar a saída.
output "tls_private_key" {
  description = "Private key to SSH"
  value       = tls_private_key.ec2_key.private_key_pem
  sensitive   = true
}
