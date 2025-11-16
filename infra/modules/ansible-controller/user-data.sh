#!/bin/bash
set -eux

# Atualizar sistema
yum update -y || apt update -y

# Criar diretório padrão para ansible
mkdir -p /opt/ansible
chmod 755 /opt/ansible

# Opcional: Python mínimo (para ansible no bootstrap)
yum install -y python3 || apt install -y python3
