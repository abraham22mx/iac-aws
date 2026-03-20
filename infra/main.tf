# Configuracion de los modulos a utilizar en terraform

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Configuracion de la region a utilizar 

provider "aws" {
  region = "us-east-1"
}

# Creacion de la llave SSH

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key" {
  filename        = "./ssh_key.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "aws_key" {
  key_name   = "ansible-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Creacion del grupo de seguridad con las configuraciones de red

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Permitir trafico desde cualquier ip para los puertos 22 SSH y 80 HTTP"

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

# Creacion de la maquina virtual

resource "aws_instance" "ubuntu_ec2" {
  ami           = "ami-0fc5d935ebf8bc3bc"  
  instance_type = "t2.micro"
  key_name      = aws_key_pair.aws_key.key_name
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "ubuntu-web-server"
  }
}
