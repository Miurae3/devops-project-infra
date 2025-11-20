
# Projeto DevOps – Infraestrutura e Automação

## Objetivo
Provisionar infraestrutura e automatizar a configuração de um ambiente Kubernetes utilizando Terraform e Ansible.

---

## Entregas
- Criação de rede completa (VPC, Subnets, IGW, Route Tables, Security Groups e regras).
- Criação de uma máquina via Terraform para atuar como **Ansible Controller**.
- Criação de duas máquinas via Terraform:  
  - **K8S Master Node**  
  - **K8S Worker Node**
- Automação via Ansible para configurar e preparar os nós do cluster Kubernetes.

---

## Processo de Execução

### 1. Provisionamento da Infraestrutura
Execute:

```bash
terraform apply
```

Isso criará toda a estrutura necessária (rede, controller, master e worker).

---

## 2. Configuração do Ansible Controller

### 2.1 Importar a chave SSH para acesso aos nós
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/id_rsa
```

Cole o conteúdo da sua chave privada dentro do arquivo.  
Depois rode:

```bash
chmod 600 ~/.ssh/id_rsa
```

---

### 2.2 Configurar Inventory do Ansible

Edite:

```bash
sudo nano /etc/ansible/hosts
```

Exemplo:

```ini
[k8smaster]
10.0.1.176 ansible_user=ubuntu

[k8sworkers]
10.0.1.193 ansible_user=ubuntu
```

Teste:

```bash
ansible -i /etc/ansible/hosts k8smaster -m ping
```

Saída esperada:

```json
{
  "changed": false,
  "ping": "pong"
}
```

---

## 3. Criação e Execução dos Playbooks

Armazene os playbooks em:

```
/ansible/project/playbooks
```

Criação:

```bash
sudo nano nome-do-playbook.yaml
```

### Ordem recomendada:

1. **masternode** – prepara o nó master do Kubernetes  
2. **workers-init** – prepara os workers  
3. **joinworker** – adiciona os workers ao cluster  

---

## 4. Testes de Verificação (no Master)

### Verificar nós:
```bash
kubectl get nodes -o wide
```

### Verificar pods:
```bash
kubectl get pods -A
```

---

## 5. Exemplo de Deploy

### Deployment de exemplo:
```bash
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
```

### Acompanhar pods:
```bash
kubectl get pods -n default -w
```

### Expor o serviço:
```bash
kubectl expose deployment nginx-deployment --type=NodePort --name=nginx
```

### Ver service:
```bash
kubectl get svc nginx
```

### Testar via curl:
```bash
curl http://ip-do-worker:porta
```

---

## Erros Comuns

### Permission denied (publickey)

Ocorre quando a máquina não possui a chave SSH configurada.

Solução:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
```

### Ansible sem acesso aos hosts

Configurar o inventory:

```ini
[machines]
192.168.0.10
192.168.0.11
```

---
