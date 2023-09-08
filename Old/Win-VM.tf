resource "aws_instance" "windows-server" {
	ami 						= "ami-0fc682b2a42e57ca2"
	instance_type 				= var.windows_instance_type
	vpc_security_group_ids      = [aws_security_group.aws-windows-sg.id]
	source_dest_check           = false
	key_name                    = aws_key_pair.key_pair.key_name
	user_data                   = data.template_file.windows-userdata.rendered

	# root disk
	root_block_device {
		volume_size           = var.windows_root_volume_size
		volume_type           = var.windows_root_volume_type
		delete_on_termination = true
		encrypted             = true
	}	

	tags = {
		Name = "${lower(var.app_name)}-${var.app_environment}-windows-server"
		Environment = var.app_environment
	}
}

resource "aws_security_group" "aws-windows-sg" {
	name = "${lower(var.app_name)}-${var.app_environment}-windows-sg"
	description = "Allow incoming connections"

	ingress {
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Allow incoming HTTP connections"
	}

	ingress {
		from_port   = 3389
		to_port     = 3389
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Allow incoming RDP connections"
	}

	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Allow incoming SSH connections"
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "${lower(var.app_name)}-${var.app_environment}-windows-sg"
		Environment = var.app_environment
	}
}
variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t2.micro"
}

variable "windows_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "30"
}

variable "windows_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server. Can be standard, gp3, gp2, io1, sc1 or st1"
  default     = "gp2"
}

variable "windows_instance_name" {
  type        = string
  description = "EC2 instance name for Windows Server"
  default     = "tfwinsrv01"
}