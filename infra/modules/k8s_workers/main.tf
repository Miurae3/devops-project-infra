# ---------------------------
# REUTILIZAR MESMA KEYPAIR
# ---------------------------
data "aws_key_pair" "ansible_controller_key_pair" {
  key_name = "ansible_controller_key"
}

# ---------------------------
# SECURITY GROUP DO TARGET
# ---------------------------
resource "aws_security_group" "k8s_workers_sg" {
  name   = "k8s_workers_sg"
  vpc_id = var.vpc_id

  # Permitir SSH SOMENTE do Security Group do Controller
  ingress {
    description = "SSH from Ansible Controller"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [var.controller_sg_id]
  }

  # Saída liberada
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_workers_sg"
  }
}

# ---------------------------
# EC2 TARGET
# ---------------------------
resource "aws_instance" "k8s_worker_1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.k8s_workers_sg.id]
  associate_public_ip_address = true
  key_name               = data.aws_key_pair.ansible_controller_key_pair.key_name

  tags = {
    Name = "k8s_worker"
    ansible = "managed"  # opcional (bom p/ inventário dinâmico depois)
  }
}
