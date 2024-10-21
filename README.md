
Este projeto utiliza Terraform para provisionar uma instância Amazon EC2 rodando Debian 12 na região `us-east-1`. A instância é configurada para instalar e iniciar automaticamente o servidor Nginx após a sua criação. O estado do Terraform é armazenado de forma remota em um bucket S3.

## Funcionalidades

- Provisionamento de uma instância EC2 (t2.micro - elegível para Free Tier) com Debian 12.
- Instalação automática e inicialização do Nginx na criação da instância, utilizando um script de inicialização (user_data).
- Criação de um par de chaves SSH para acesso seguro à instância.
- Configuração de um backend no S3 para armazenar o estado do Terraform.
- Configuração de um grupo de segurança para permitir acesso SSH e HTTP à instância EC2.

## Pré-requisitos

- Terraform instalado.
- Credenciais AWS configuradas corretamente no seu sistema (~/.aws/credentials).
- Um bucket S3 existente e uma tabela DynamoDB para gerenciamento do estado:
- Bucket S3: meu-bucket-terraform-states

## Estrutura de Arquivos
```
.
├── backend.tf         # Configuração do backend do Terraform (S3 + DynamoDB)
├── main.tf            # Script principal do Terraform para provisionamento da EC2
├── outputs.tf         # Valores de saída do Terraform (IP público da EC2, chave SSH)
├── variables.tf       # Arquivo de variáveis (contém o ID da AMI, região, etc.)
├── .gitignore         # Arquivo gitignore (exclui estado do Terraform, chaves, etc.)
├── README.md          # Este arquivo README
└── modules            # Diretório para módulos reutilizáveis
    ├── vpc            # Módulo VPC
    │   ├── main.tf    # Configurações principais da VPC
    │   ├── outputs.tf # Saídas do módulo VPC
    │   └── vars.tf    # Variáveis do módulo VPC
    ├── security       # Módulo de Segurança
    │   ├── main.tf    # Configurações principais de segurança
    │   ├── outputs.tf # Saídas do módulo de segurança
    │   └── vars.tf    # Variáveis do módulo de segurança
    └── ec2            # Módulo EC2
        ├── main.tf    # Configurações principais da instância EC2
        ├── outputs.tf # Saídas do módulo EC2
        └── vars.tf    # Variáveis do módulo EC2

```
## main.tf

Este arquivo provisiona a infraestrutura:

1. Configuração do provedor: Especifica o provedor AWS e a região (us-east-1).
2. Par de chaves: Cria um par de chaves usando tls_private_key para acesso SSH à instância.
3. Grupo de segurança: Define um grupo de segurança que permite SSH (porta 22) e HTTP (porta 80).
4. Instância EC2: Cria uma instância EC2 com a AMI especificada e um script user_data que instala e inicia o Nginx.

```
provider "aws" {
  region = "us-east-1"
}

# Par de chaves e grupo de segurança
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "debian_key_pair" {
  key_name   = "debian_key_pair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instância EC2 com instalação do Nginx via user_data
resource "aws_instance" "debian_ec2" {
  ami           = var.debian_ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.debian_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh_http.name]

  root_block_device {
    volume_size = 8
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
}
```

## outputs.tf

Define os valores de saída após o provisionamento da infraestrutura:

- Endereço IP público da instância EC2.
- Chave privada para acesso SSH.

```
output "ec2_public_ip" {
  description = "Endereço IP público da instância EC2"
  value       = aws_instance.debian_ec2.public_ip
}

output "private_key" {
  description = "Chave privada para acesso SSH"
  value       = tls_private_key.example.private_key_pem
  sensitive   = true
}

```

## variables.tf

Contém a variável para o ID da AMI Debian usada para provisionar a instância EC2. Você pode alterar este valor para outra AMI Debian, se necessário.

```
variable "debian_ami_id" {
  default = "ami-0b2f6494ff0b07a0e"
}
```

# Instruções de Uso

## 1. Inicializar o projeto:

Execute o comando a seguir para inicializar o Terraform e baixar os provedores necessários e configurar o backend:

```
terraform init
```

## 2. Aplicar o plano do Terraform:
Gere um plano de execução detalhando as ações necessárias para alinhar a infraestrutura real com o código Terraform. Ele mostra quais recursos serão criados, modificados ou destruídos, sem realizar nenhuma mudança real:

```
terraform plan

```

## 3. Acessar a instância EC2:
Você pode acessar a instância EC2 via SSH usando a chave privada fornecida no output:

```
ssh -i <path_to_private_key> ec2-user@<ec2_public_ip>

```

Você também pode acessar o servidor Nginx através do navegador usando o endereço IP público:

```
http://<ec2_public_ip>

```

## 4. Destruir a infraestrutura:
Para remover e limpar a infraestrutura criada, use o comando terraform destroy:

```
terraform destroy

```
## Melhorias 

- Separado em módulos para facilitar gerenciamento, alterações e novas configurações.
- Adicionado configuração de backend para armazenar arquivo tfstate de forma que possa ser alterado sem criar arquivo lock e sendo possível atualização do tfstate.
- Habilitação da porta 80 para acesso ao Nginx com liberação apenas ao IP local.

## Notas
- Certifique-se de que você tem as permissões AWS necessárias para criar instâncias EC2, buckets S3 e grupos de segurança.
- O ID da AMI fornecido no arquivo variables.tf corresponde à Debian 12 na região us-east-1. Se você usar uma região diferente, será necessário atualizar o ID da AMI.
- O par de chaves gerado pelo Terraform é sensível e deve ser armazenado com segurança.

## Observação

- Como a criação da infraestrutura é em carater de teste foi utilizado apenas uma zona de disponibilidade ao invés de 3.
