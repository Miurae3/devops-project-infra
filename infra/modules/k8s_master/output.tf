
# OUTPUTS úteis
output "target_private_ip" {
  value = aws_instance.k8s_master.private_ip
}

output "target_public_ip" {
  value = aws_instance.k8s_master.public_ip
}
