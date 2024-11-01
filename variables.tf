variable "region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  default     = "t2.micro"
}

# variable "aws_eip"{
#   description = "IP de AWS"
#   default = "192.684.2.1"
#}