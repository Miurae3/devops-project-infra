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

output "vpc_id" {
  value = aws_vpc.ansible_controller_vpc.id
}

output "subnet_id" {
  value = aws_subnet.ansible_controller_subnet.id
}

output "controller_sg_id" {
  value = aws_security_group.ansible_controller_sg.id
}