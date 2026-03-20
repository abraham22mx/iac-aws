
# Escribir en la salida estandart la direccion ip asignada a la maquina virtual que se genero

output "web_public_ips" {
  description = "Direccion IP pública del servidor web"
  value       = aws_instance.ubuntu_ec2.public_ip
}
