# ---------------------------
# REUTILIZAR MESMA KEYPAIR
# ---------------------------
data "aws_key_pair" "ansible_controller_key_pair" {
  key_name = "ansible_controller_key"
}

resource "aws_security_group" "k8s_workers_sg" {
  name   = "k8s_workers_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from Controller"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [var.controller_sg_id]
  }

  ingress {
    description = "kubelet (master worker)"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Cluster internal TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Cluster internal UDP"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
