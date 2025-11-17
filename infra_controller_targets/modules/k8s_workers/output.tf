
# OUTPUTS úteis
output "target_private_ip" {
  value = aws_instance.k8s_worker_1.private_ip
}

output "target_public_ip" {
  value = aws_instance.k8s_worker_1.public_ip
}
