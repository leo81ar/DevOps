# Define la región en la que deseas crear la infraestructura
provider "aws" {
  region = "us-east-1" # Cambia esto a la región deseada
}

# Crea una VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Crea subredes públicas en dos zonas de disponibilidad diferentes
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Cambia esto a la zona de disponibilidad deseada
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # Cambia esto a la zona de disponibilidad deseada
  map_public_ip_on_launch = true
}

# Crea subredes privadas en dos zonas de disponibilidad diferentes
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a" # Cambia esto a la zona de disponibilidad deseada
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b" # Cambia esto a la zona de disponibilidad deseada
}

# Crea dos instancias EC2 en diferentes zonas de disponibilidad
resource "aws_instance" "web_instance_a" {
  ami           = "ami-0fc682b2a42e57ca2" # Cambia esto al ID de la AMI deseada
  instance_type = "t2.micro"             # Cambia esto al tipo de instancia deseado
  subnet_id     = aws_subnet.public_subnet_a.id

  user_data = <<-EOF
              #!/bin/bash
              echo "Esta es la instancia A en la región ${aws_region.current.name}"
              EOF
}

resource "aws_instance" "web_instance_b" {
  ami           = "ami-0fc682b2a42e57ca2" # Cambia esto al ID de la AMI deseada
  instance_type = "t2.micro"             # Cambia esto al tipo de instancia deseado
  subnet_id     = aws_subnet.public_subnet_b.id

  user_data = <<-EOF
              #!/bin/bash
              echo "Esta es la instancia B en la región ${aws_region.current.name}"
              EOF
}

# Crea un grupo de destino (target group)
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}

# Agrega las instancias al grupo de destino
resource "aws_lb_target_group_attachment" "instance_a" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.web_instance_a.id
}

resource "aws_lb_target_group_attachment" "instance_b" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.web_instance_b.id
}

# Crea el balanceador de carga y lo asocia al grupo de destino
resource "aws_lb" "my_load_balancer" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  enable_deletion_protection = false

  enable_http2 = true

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-load-balancer"
  }

  enable_deletion_protection = false

  enable_http2 = true

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-load-balancer"
  }

  enable_deletion_protection = false

  enable_http2 = true

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-load-balancer"
  }
}

# Salida con la dirección DNS del balanceador de carga
output "load_balancer_dns" {
  value = aws_lb.my_load_balancer.dns_name
}