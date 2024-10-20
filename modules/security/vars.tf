
# Define a variável para o nome do projeto
# Tipo string, valor padrão "VExpenses".
variable "projeto" {
  description = "Nome do projeto"
  type        = string
  default     = "VExpenses"
}

# Define a variável para o nome do candidato
# Tipo string, valor padrão "william".
variable "candidato" {
  description = "Nome do candidato"
  type        = string
  default     = "william"
}

# Define a variável para o ID da VPC
# Tipo string, sem valor padrão.
variable "vpc_id" {
  type = string
}