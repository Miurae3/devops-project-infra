16/11/25

# README — Estrutura mínima para subir uma EC2 com SSH funcional

Este documento descreve **tudo o que é necessário** para criar uma instância EC2 com acesso SSH funcional usando Terraform. Também explica **por que sua primeira configuração não funcionou** e como os recursos de rede (VPC, subnets, IGW e Security Groups) se relacionam.

---

# 1. O que é necessário para acessar uma EC2 via SSH

Para que qualquer instância EC2 seja acessível por SSH **a partir da internet**, quatro componentes são obrigatórios:

## ✔ 1. VPC

Rede virtual onde todos os recursos AWS são criados.

## ✔ 2. Subnet pública

Uma subnet só é "pública" quando possui **rota para um Internet Gateway**. Sem isso, mesmo que a EC2 tenha IP público, ela não recebe tráfego externo.

## ✔ 3. Internet Gateway (IGW)

O IGW permite que tráfego público (internet) entre e saia da VPC.
Sem IGW → **nenhum tráfego chega**, mesmo com IP público → SSH falha.

## ✔ 4. Route Table associada à Subnet

Deve conter:

```
0.0.0.0/0 → igw-xxxxx
```

Sem essa rota, a subnet não é pública e o SSH não funciona.

## ✔ 5. Security Group

O SG deve liberar porta **22/tcp** para o seu IP público.

Exemplo:

```
22/tcp → seu_IP/32
```

Se liberar 0.0.0.0/0 funciona também, mas é inseguro.

---

# 2. Por que sua primeira configuração *não funcionava*

Os problemas mais comuns foram exatamente estes:

### **❌ Você criou apenas o Security Group, mas não toda a infraestrutura de rede necessária.**

Sem VPC + Subnet pública + IGW + Rota pública, a EC2 fica isolada.

Mesmo com:

* IP público
* Porta 22 liberada

Ainda assim o SSH não chega porque:

* Não havia rota 0.0.0.0/0 → IGW
* Subnet não era pública

### Por isso, com o código corrigido começou a funcionar.

A correção criou:

* VPC
* Subnet pública
* IGW
* Route Table → IGW
* Associação da Route Table com a Subnet
* Security Group com entrada em 22/tcp

Com isso, o caminho ficou assim:

```
internet → IGW → route table → subnet → instancia EC2
```

E o SSH finalmente funcionou.

---

# 3. Fluxo correto do tráfego SSH

```
(SEU PC)
   ↓  porta 22
internet
   ↓
Internet Gateway (IGW)
   ↓
Route Table com rota 0.0.0.0/0 → IGW
   ↓
Subnet pública
   ↓
EC2 (com Security Group liberando 22)
```

Se **qualquer peça** estiver faltando, o SSH falha.

---

# 4. Visão geral da infraestrutura criada

### **Recursos essenciais:**

* `aws_vpc`
* `aws_subnet`
* `aws_internet_gateway`
* `aws_route_table`
* `aws_route_table_association`
* `aws_security_group`
* `aws_instance`

### **Ordem lógica de construção:**

1. Criar VPC
2. Criar Subnet
3. Criar IGW
4. Route Table apontando para IGW
5. Associar Route Table à Subnet
6. Criar Security Group permitindo SSH
7. Criar EC2 conectada à Subnet + SG

---

# 5. Erros comuns que impedem SSH

| Problema                    | Consequência               |
| --------------------------- | -------------------------- |
| Subnet sem rota para o IGW  | Instância fica inacessível |
| IGW não anexado             | Nada entra ou sai da VPC   |
| SG sem porta 22             | SSH negado                 |
| Usar o IP errado no SG      | Acesso bloqueado           |
| Criar EC2 em subnet privada | Sem acesso externo         |

---

# 6. Conclusão

Para rodar uma EC2 com SSH funcional, é essencial **montar corretamente toda a infraestrutura de rede**, não apenas liberar porta no Security Group.

Agora que sua instância funciona via SSH, podemos avançar para a **Etapa 3** quando você quiser.

---

