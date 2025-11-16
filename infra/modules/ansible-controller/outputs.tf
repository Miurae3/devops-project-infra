output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.ansible_controller.id
}

output "instance_public_ip" {
  description = "Endereço de Ip publico da instância"
  value       = aws_instance.ansible_controller.public_ip
}

output "instance_type" {
  description = "Tipo da instância"
  value       = aws_instance.ansible_controller.instance_type

}

output "private_key" {
  value = tls_private_key.ansible_controller_key.private_key_pem
  sensitive = true
}