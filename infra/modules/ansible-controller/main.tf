# ---------------------------
# 1. KEY PAIR
# ---------------------------
resource "tls_private_key" "ansible_controller_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ansible_controller_key_pair" {
  key_name   = "ansible_controller_key"
  public_key = tls_private_key.ansible_controller_key.public_key_openssh
}

resource "local_file" "ansible_controller_private_key" {
  content         = tls_private_key.ansible_controller_key.private_key_pem
  filename        = "ansible_controller_key.pem"
  file_permission = "400"
}

# ---------------------------
# 2. VPC
# ---------------------------
resource "aws_vpc" "ansible_controller_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ansible_controller_vpc"
  }
}

# ---------------------------
# 3. SUBNET PÚBLICA
# ---------------------------
resource "aws_subnet" "ansible_controller_subnet" {
  vpc_id                  = aws_vpc.ansible_controller_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "ansible_controller_subnet"
  }
}

# ---------------------------
# 4. INTERNET GATEWAY
# ---------------------------
resource "aws_internet_gateway" "ansible_controller_igw" {
  vpc_id = aws_vpc.ansible_controller_vpc.id

  tags = {
    Name = "ansible_controller_igw"
  }
}

# ---------------------------
# 5. ROTA PARA INTERNET
# ---------------------------
resource "aws_route_table" "ansible_controller_rt" {
  vpc_id = aws_vpc.ansible_controller_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ansible_controller_igw.id
  }

  tags = {
    Name = "ansible_controller_rt"
  }
}

resource "aws_route_table_association" "ansible_controller_rta" {
  subnet_id      = aws_subnet.ansible_controller_subnet.id
  route_table_id = aws_route_table.ansible_controller_rt.id
}

# ---------------------------
# 6. SECURITY GROUP
# ---------------------------
resource "aws_security_group" "ansible_controller_sg" {
  name   = "ansible_controller_sg"
  vpc_id = aws_vpc.ansible_controller_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["191.201.65.248/32"] # <-- substitua
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# 7. IAM ROLE E POLÍTICA
# ---------------------------

resource "aws_iam_role" "ansible_controller_role" {
  name = "ansible_controller_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ansible_controller_role_attachment_ssm" {
  role       = aws_iam_role.ansible_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ansible_controller_role_attachment_ec2" {
  role       = aws_iam_role.ansible_controller_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ansible_controller_instance_profile" {
  name = "ansible_controller_instance_profile"
  role = aws_iam_role.ansible_controller_role.name
}

# ---------------------------
# 8. EC2 INSTANCE CONTROLLER
# ---------------------------
resource "aws_instance" "ansible_controller" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ansible_controller_key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.ansible_controller_instance_profile.name
  user_data = file("${path.module}/user-data.sh")

  subnet_id              = aws_subnet.ansible_controller_subnet.id
  vpc_security_group_ids = [aws_security_group.ansible_controller_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}
