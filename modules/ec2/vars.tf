
# Define a variável de nome do projeto.
# Tipo string, com valor padrão "VExpenses".
variable "projeto" {
  description = "Nome do projeto"
  type        = string
  default     = "VExpenses"
}

# Define a variável de nome do candidato.
# Tipo string, com valor padrão "william".
variable "candidato" {
  description = "Nome do candidato"
  type        = string
  default     = "william"
}

# Define a variável para o ID da subnet.
# Tipo string, sem valor padrão.
variable "subnet_id" {
  type = string
}

# Define a variável para o ID do Security Group
# Tipo string, sem valor padrão.
variable "sg_id" {
  type = string
}
