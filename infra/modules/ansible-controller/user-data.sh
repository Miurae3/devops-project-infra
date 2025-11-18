#!/bin/bash
set -eux

ANSIBLE_HOME="/home/ubuntu/ansible"
PROJECT_DIR="$ANSIBLE_HOME/project"
VENV_DIR="$ANSIBLE_HOME/venv"

# Atualizar sistema
apt update -y
apt install -y python3 python3-venv python3-pip tar git

# Criar pastas
mkdir -p $PROJECT_DIR/playbooks
mkdir -p $PROJECT_DIR/roles
mkdir -p $PROJECT_DIR/group_vars
mkdir -p $PROJECT_DIR/host_vars

# Criar inventário
cat <<EOF > $PROJECT_DIR/inventory.ini
[local]
localhost ansible_connection=local
EOF

# Playbook de teste
cat <<EOF > $PROJECT_DIR/test.yml
- name: Teste Ansible Automático
  hosts: local
  tasks:
    - name: Mostrar mensagem
      ansible.builtin.debug:
        msg: "Ansible instalado automaticamente via user-data!"
EOF

# Criar virtualenv
python3 -m venv $VENV_DIR

# Instalar Ansible dentro do venv
source $VENV_DIR/bin/activate
pip install --upgrade pip
pip install ansible

# Criar script em /etc/profile.d para ativar o venv em todo login
cat <<EOF > /etc/profile.d/ansible-activate.sh
#!/bin/bash
# Ativar o Ansible Venv automaticamente
source /home/ubuntu/ansible/venv/bin/activate
EOF

chmod +x /etc/profile.d/ansible-activate.sh

# Permissões
chown -R ubuntu:ubuntu /home/ubuntu/ansible
