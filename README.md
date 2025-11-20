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

            - curl http://ip-do-worker:port
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
            Configure o arquivo hosts em /etc/ansible/hosts, adicione os grupos como [machines] e depois os ips logos abaixo:
            [machines]
            xxx.xx.xx.xx
