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


ver seu ip: https://ifconfig.me/










Projeto devops!

Parte: Infraestrutura
Motivo: Ambiente automatizado de deploy

Entregas:

-  Criação de rede (VPC/SUBNET/IGW/RT/SECURITY GROUP/REGRAS)
-  Criação de uma máquina via terraform com a função de ser o nosso controller do Ansible (Ansible Controller)
-  Criação de duas máquinas via terraform, uma sendo um node Master do K8S e um Worker
-  Automação via ansible para realizar as configurações necessárias nas duas maquinas do K8S


Processos:
   - Inicio:
      Rode "terraform apply" para subir os recursos

   - Ansible-controller
      Acesse a máquina via ssh e execute os seguintes comandos:

         mkdir -p ~/.ssh
         chmod 700 ~/.ssh
         nano ~/.ssh/id_rsa

         e após isso cole a chave dentro do arquivo, salve e feche. Como útlimo comando rode 
         chmod 600 ~/.ssh/id_rsa
      
      Isso vai permitir o acesso via ssh para os outros workers com a mesma key pair:

         - Configuração do Ansible (Inventory)
            Execute:
            sudo nano /etc/ansible/hosts
            
            e adicione os ips privados das maquinas nesse estilo:
            [k8smaster]
            10.0.1.176 ansible_user=ubuntu

            Após isso pode tentar realizar um pin com ansbile, tipo:
            ansible -i /etc/ansible/hosts k8smaster -m ping

            a saida de sucesso é tipo essa:

            10.0.1.193 | SUCCESS => {
                "ansible_facts": {
                    "discovered_interpreter_python": "/usr/bin/python3.12"
                },
                "changed": false,
                "ping": "pong"
            }

         - Criação de playbooks
            A criação dos playbooks eu recomendo criar externamente e depois copiar para dentro do Controller.
            Acesse /ansible/project/playbooks e crie o seu playbook tipo, sudo nano nome-do-seu-playbook

            No projeto tem alguns playbooks essenciais, segue a ordem de execução deles:
            1 - masternode - você vai preparar o seu node master do k8s
            2 - workers-init - nele você vai preparar os workers para entrarem no cluster
            3 - joinworker - você vai adicionar os workers no seu cluster


         - Testes de para verificar sucesso(tudo isso dentro do seu master)

            - kubectl get nodes -o wide
               Retorna a lista de nós do cluster com detalhes adicionais (“wide”):
               STATUS: se o nó está pronto para rodar pods
               ROLES: função (control-plane ou worker)
               VERSION: versão do kubelet
               INTERNAL-IP: IP usado para comunicação interna
               OS-IMAGE e KERNEL-VERSION
               CONTAINER-RUNTIME (containerd, docker, etc.)

            - kubectl get pods -A
               Lista todos os pods de todos os namespaces (-A = all namespaces).
               É usado para confirmar:
               Calico (CNI) funcionando
               CoreDNS funcionando
               kube-apiserver, scheduler, controller-manager, etcd no master
               kube-proxy em todos os nós

         - Exemplo de deploy

            - kubectl apply -f https://k8s.io/examples/application/deployment.yaml
               Cria um Deployment de exemplo (nginx) fornecido pela documentação oficial do Kubernetes:
               2 réplicas de nginx
               Pod template simples para teste
               Serve para validar o cluster e o CNI.

            - kubectl get pods -n default -w
               Mostra os pods do namespace default e segue assistindo mudanças (watch).
               Permite acompanhar:
               ContainerCreating
               Pull da imagem
               Startup
               Running
            
            - kubectl expose deployment nginx-deployment --type=NodePort --name=nginx
               Cria um Service do tipo NodePort (porta exposta nos nodes) redirecionando para os pods do Deployment.
               NodePort = cria uma porta alta (30000–32767) acessível em qualquer nó do cluster.

            - kubectl get svc nginx
               Mostra detalhes do Service nginx:
               CLUSTER-IP: IP interno
               PORT(S): exemplo → 80:31500/TCP
               Porta 80 interna → Porta 31500 exposta nos nodes

            - curl http://ip-do-worker:31500
               Ele deve retorna a página do ngnix

   
      


Erros conhecidos:
   - Permission denied (publickey)
      Esse erro provém da falta da chave no Agente que está tentando conectar via ssh em outra máquina, isso pode acontecer ao tentar usar um playbook em uma máquina oua cessar via ssh uma máquina de outra máquina.

      * Solução:
         -  SSH de uma máquina para outra:
            Copie a key.pem gerada pelo projeto nesse caso aqui (ansible_controller_key.pem) para dentro da máquina que ira fazer o ssh, nesse caso rode os 
            seguintes comandos para criar no maquina pai:
            
            mkdir -p ~/.ssh
            chmod 700 ~/.ssh
            nano ~/.ssh/id_rsa
         
            e após isso cole a chave dentro do arquivo, salve e feche. Como útlimo comando rode?

            chmod 600 ~/.ssh/id_rsa

            depois tente usar o ssh user@ip novamente para conectar

         - Playbook do Ansible para outra máquina:
