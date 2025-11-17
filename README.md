📘 README — Infraestrutura mínima para acesso SSH em EC2 + Preparação do Ambiente Kubernetes (Etapa 6)
📅 Atualizações

16/11/25 — Infraestrutura AWS para SSH funcional

17/11/25 — Etapa 6: Repositório Kubernetes + Containerd

1. 📡 Infraestrutura mínima para acessar uma EC2 via SSH

Este documento descreve todos os recursos necessários para criar uma instância EC2 acessível por SSH usando Terraform.
Também explica por que a primeira versão não funcionava e como os elementos de rede da AWS se conectam.

Para que uma EC2 seja acessível pela internet via SSH, são obrigatórios cinco componentes de rede:

✔ 1. VPC

A VPC é a rede privada onde todos os recursos são criados.

✔ 2. Subnet pública

Uma subnet só é considerada pública quando possui rota para um Internet Gateway.
Sem isso, mesmo que a EC2 tenha IP público, ela permanece isolada.

✔ 3. Internet Gateway (IGW)

Responsável por permitir tráfego de/para a internet.
Sem IGW → nenhum pacote chega na EC2 → SSH falha.

✔ 4. Route Table

A subnet pública precisa de uma rota padrão:

0.0.0.0/0 → igw-xxxxx


Sem essa rota, a EC2 não será acessível externamente.

✔ 5. Security Group

O Security Group deve liberar a porta 22/tcp:

22/tcp → seu_IP/32


0.0.0.0/0 funciona, mas é inseguro.

2. ❌ Por que sua primeira configuração não funcionava

Sua primeira tentativa criava apenas o Security Group, mas não:

VPC

Subnet pública

Internet Gateway

Route Table com rota para o IGW

Associação da Route Table com a Subnet

Mesmo com:

IP público

Porta 22 liberada

A EC2 continuava inacessível porque:

A subnet não tinha rota para internet

Não havia IGW associado

A EC2 estava isolada dentro da VPC

✔ Após a correção, estes recursos foram criados:

VPC

Subnet pública

Internet Gateway

Route Table com rota para o IGW

Associação entre Subnet e Route Table

Security Group com porta 22 liberada

EC2 conectada corretamente

Caminho final do tráfego SSH:

internet → IGW → Route Table → Subnet pública → EC2 (porta 22 liberada)

3. 🔁 Fluxo do tráfego SSH
(SEU PC)
   ↓ (22/tcp)
internet
   ↓
Internet Gateway
   ↓
Route Table (0.0.0.0/0 → IGW)
   ↓
Subnet pública
   ↓
EC2 (SG permitindo SSH)


Se qualquer parte estiver faltando → SSH não funciona.

4. 🧱 Infraestrutura criada
Recursos essenciais

aws_vpc

aws_subnet

aws_internet_gateway

aws_route_table

aws_route_table_association

aws_security_group

aws_instance

Ordem lógica

Criar VPC

Criar Subnet

Criar Internet Gateway

Criar Route Table

Associar Route Table à Subnet

Criar Security Group

Criar EC2

5. ⚠ Erros comuns que impedem SSH
Erro	Consequência
Subnet sem rota para IGW	EC2 isolada
IGW ausente	Sem tráfego externo
SG sem porta 22	SSH bloqueado
Usar IP errado no SG	Conexão negada
EC2 em subnet privada	Sem acesso externo
6. 🎯 Conclusão

Para conectar via SSH em uma EC2, é fundamental configurar corretamente toda a estrutura de rede, e não apenas o Security Group.

Com essa base pronta, avançamos para a preparação da instância para o Kubernetes.

7. 🤖 Adição do Ansible na EC2

O Ansible foi instalado automaticamente usando user-data durante a criação da instância.

8. 🚀 Etapa 6 — Repositório Kubernetes + Instalação do Containerd

(17/11/25)

Esta etapa prepara a EC2 para receber os binários Kubernetes.
Configuramos o repositório pkgs.k8s.io, instalamos o containerd e aplicamos otimizações recomendadas pela CNCF.

🎯 Objetivos

Registrar o repositório oficial Kubernetes

Importar a chave GPG correta (evitando erros NO_PUBKEY)

Instalar e configurar o containerd

Ajustar parâmetros do sistema

Habilitar o uso de SystemdCgroup

🧩 Implementações realizadas
✔ 1. Atualização do APT

Garantimos o uso dos repositórios mais recentes.

✔ 2. Instalação de dependências

Incluindo ferramentas para trabalhar com GPG e repositórios HTTPS.

✔ 3. Baixar e registrar chave GPG oficial

A chave foi armazenada em:

/etc/apt/keyrings/kubernetes-apt-keyring.gpg

✔ 4. Criar o repositório Kubernetes

Arquivo gerado:

/etc/apt/sources.list.d/kubernetes.list

✔ 5. Instalação do containerd

Container runtime recomendado para clusters Kubernetes modernos.

✔ 6. Configuração do containerd

Foi regenerado o arquivo:

/etc/containerd/config.toml


Com ajustes:

SystemdCgroup = true

conformidade com kubelet e CRI

✔ 7. Reinício e habilitação

O containerd foi reiniciado e configurado para iniciar automaticamente.