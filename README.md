# Oracle Cloud Service Mesh mTLS

Este documento tem por objetivo demonstrar como usar o Service Mesh nativo da Oracle Cloud juntamente com o Oracle Cloud for Kubernetes para implantar containers e serviços com autenticação mTLS.

# Criando o cluster de Kubernetes

Para criar o cluster de kubernetes, é necessário:

    Criar as políticas de acesso para o grupo de usuários do OKE
    Criar o cluster de kubernetes em um compartimento

###Criar as políticas de acesso para o grupo de usuários do OKE

Para criar, atualizar e excluir clusters e pools de nós, os usuários que não são membros do grupo Administradores devem ter permissões para trabalhar com recursos relacionados ao cluster. Para dar aos usuários o acesso necessário, você deve criar uma política com várias declarações de política necessárias para os grupos aos quais esses usuários pertencem:

No Console, abra o menu de navegação e clique em Identidade e Segurança. Em Identidade, clique em Políticas. Uma lista das políticas no compartimento que você está visualizando é exibida.

Selecione o compartimento raiz do arrendamento ou um compartimento individual contendo recursos relacionados ao cluster na lista à esquerda.

Clique em Criar Política.

Digite o seguinte:

**Nome**: Um nome para a política (por exemplo, acme-dev-team-oke-required-policy) que é exclusivo dentro do compartimento. Se você estiver criando a política no compartimento raiz do arrendamento, o nome deve ser exclusivo em todas as políticas do seu arrendamento. Você não pode mudar isso mais tarde. Evite inserir informações confidenciais.

**Descrição**: Uma descrição amigável. Você pode mudar isso mais tarde, se quiser.

**Instrução**: As seguintes declarações de política necessárias para permitir que os usuários usem o Container Engine for Kubernetes para criar, atualizar e excluir clusters e pools de nós:


    Allow group <group-name> to manage instance-family in <location>
    Allow group <group-name> to use subnets in <location>
    Allow group <group-name> to read virtual-network-family in <location>
    Allow group <group-name> to inspect compartments in <location>
    Allow group <group-name> to use vnics in <location>
    Allow group <group-name> to use network-security-groups  in <location>
    Allow group <group-name> to use private-ips  in <location>
    Allow group <group-name> to manage public-ips  in <location>

A seguinte declaração de política necessária para permitir que os usuários executem qualquer operação em recursos relacionados ao cluster (esta política de 'catch-all' efetivamente torna todos os administradores de usuários no que diz respeito aos recursos relacionados ao cluster):

    Allow group <group-name> to manage cluster-family in <location>

In the above policy statements, replace **<location>** with either tenancy (if you are creating the policy in the tenancy's **root** compartment) or compartment **<compartment-name>** (if you are creating the policy in an individual compartment).
Nota

Dependendo do tipo de cluster, algumas declarações de política necessárias podem não ser necessárias:

To work with "VCN-native" clusters (where the Kubernetes API endpoint is fully integrated with your VCN), the use network-security-groups and use public-ips policy statements are only necessary if the clusters' network security group and public IP address options are selected.

To work with clusters where the public Kubernetes API endpoint is in an Oracle-managed tenancy, the use network-security-groups, use private-ips, and use public-ips policy statements are unnecessary.

Para obter mais informações sobre clusters nativos do VCN, consulte Plano de Controle de Cluster do Kubernetes e API do Kubernetes.

**Tags**: Se você tem permissões para criar um recurso, então você também tem permissões para aplicar tags de forma livre a esse recurso. Para aplicar uma tag definida, você deve ter permissões para usar o namespace da tag. Para mais informações sobre marcação, consulte Tags de Recursos. Se você não tiver certeza se deve aplicar tags, ignore esta opção (você pode aplicar tags mais tarde) ou pergunte ao seu administrador.

Clique em **Criar**.

###Criar o cluster de kubernetes em um compartimento

Baseado na documentação oficial (https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm), você pode criar o cluster de kubernetes (OKE) desta forma:

No Console, abra o menu de navegação e clique em Developer Services. Em Contêineres, clique em Clusters Kubernetes (OKE).

Escolha um compartimento no qual você tem permissão para trabalhar.

Na página Lista de Clusters, clique em Criar Cluster.

Na caixa de diálogo Criar Cluster, selecione Criação Rápida e clique em Iniciar Fluxo de Trabalho.

Na página Criar Cluster, basta aceitar os detalhes de configuração padrão para o novo cluster ou especificar alternativas da seguinte maneira:

**Nome**: O nome do novo cluster. Aceite o nome padrão ou insira um nome de sua escolha. Evite inserir informações confidenciais.

**Compartimento**: O compartimento no qual criar o novo cluster e os recursos de rede associados.

**Versão do Kubernetes**: A versão do Kubernetes a ser executada nos nós do plano de controle e nos nós de trabalho do cluster. Aceite a versão padrão ou selecione uma versão de sua escolha. Entre outras coisas, a versão do Kubernetes determina o conjunto padrão de controladores de admissão que estão ativados no cluster criado (consulte Controladores de Admissão Suportados).

**Ponto Final da API Kubernetes**: O tipo de acesso ao ponto final da API Kubernetes do cluster. O ponto final da API do Kubernetes é privado (acessível por outras sub-redes no VCN) ou público (acessível diretamente da Internet):

**Endpoint Privado**: Uma sub-rede regional privada é criada e o ponto final da API do Kubernetes está hospedado nessa sub-rede. O ponto final da API do Kubernetes recebe um endereço IP privado.

**Endpoint Público**: Uma sub-rede regional pública é criada e o ponto final da API do Kubernetes está hospedado nessa sub-rede. O ponto final da API do Kubernetes recebe um endereço IP público, bem como um endereço IP privado.
Os endpoints privados e públicos recebem uma regra de segurança (como parte de uma lista de segurança) que concede acesso ao endpoint da API do Kubernetes (TCP/6443).

Para obter mais informações, consulte Plano de Controle de Cluster Kubernetes e API Kubernetes.
Nós de Trabalho do Kubernetes: O tipo de acesso aos nós de trabalho do cluster. Os nós de trabalho são privados (acessíveis através de outras sub-redes VCN) ou públicos (acessíveis diretamente da Internet):

**Privado**: Uma sub-rede regional privada é criada para hospedar nós de trabalho. Os nós de trabalho recebem um endereço IP privado.

**Público**: Uma sub-rede regional pública é criada para hospedar nós de trabalho. Os nós de trabalho recebem um endereço IP público, bem como um endereço IP privado.
Observe que uma sub-rede regional pública é sempre criada para hospedar balanceadores de carga em clusters criados no fluxo de trabalho 'Criação Rápida', independentemente da sua seleção aqui.

**Forma**: A forma a ser usada para cada nó no pool de nós. A forma determina o número de CPUs e a quantidade de memória alocada para cada nó. Se você selecionar uma forma flexível, poderá especificar explicitamente o número de CPUs e a quantidade de memória. A lista mostra apenas as formas disponíveis no seu aluguel que são suportadas pelo Container Engine for Kubernetes. Consulte Imagens Suportadas (incluindo Imagens Personalizadas) e Formas para Nós de Trabalhadores.

**Número de Nós**: O número de nós de trabalho a serem criados no pool de nós, colocados na sub-rede regional criada para o cluster. Os nós são distribuídos da maneira mais uniforme possível entre os domínios de disponibilidade em uma região (ou, no caso de uma região com um único domínio de disponibilidade, entre os domínios de falha nesse domínio de disponibilidade).

Aceite o tamanho padrão dos volumes de inicialização do nó de trabalho (conforme determinado a partir da imagem padrão do OKE que está sendo usada) ou clique em Especificar um Tamanho de Volume de Inicialização Personalizado: e especifique um tamanho alternativo para os volumes de inicialização do nó de trabalho em Tamanho do Volume de Inicialização em GB:. Se você especificar um tamanho de volume de inicialização personalizado, ele deve ser maior do que o tamanho de volume de inicialização padrão da imagem. Os tamanhos mínimo e máximo que você pode especificar são 50 GB e 32 TB, respectivamente. Consulte Tamanhos de Volume de Inicialização Personalizados.

Aceite os padrões para opções avançadas de cluster ou clique em Mostrar Opções Avançadas e especifique alternativas da seguinte maneira:

Ative as políticas de verificação de imagem neste cluster: (Opcional) Permitir ou não apenas a implantação de imagens do Oracle Cloud Infrastructure Registry que tenham sido assinadas por chaves de criptografia mestras específicas. Especifique a chave de criptografia e o cofre que a contém. Consulte Forçando o Uso de Imagens Assinadas do Registro.

**Chave SSH Pública**: (Opcional) A parte da chave pública do par de chaves que você deseja usar para acesso SSH a cada nó no pool de nós. A chave pública está instalada em todos os nós de trabalho do cluster. Observe que, se você não especificar uma chave SSH pública, o Container Engine for Kubernetes fornecerá uma. No entanto, como você não terá a chave privada correspondente, não terá acesso SSH aos nós de trabalho. Observe que, se você especificar que deseja que os nós de trabalho no cluster sejam hospedados em uma sub-rede regional privada, não poderá usar o SSH para acessá-los diretamente (consulte Conectando-se a Nós de Trabalho em Sub-redes Privadas Usando SSH).

**Rótulos do Kubernetes**: (Opcional) Um ou mais rótulos (além de um rótulo padrão) para adicionar aos nós de trabalho no pool de nós para permitir a segmentação de cargas de trabalho em pools de nós específicos.

Clique em Próximo para revisar os detalhes que você inseriu para o novo cluster.

Clique em Criar Cluster para criar os novos recursos de rede e o novo cluster.

O Container Engine para Kubernetes começa a criar recursos (como mostrado na caixa de diálogo Criando cluster e recursos de rede associados):

os recursos de rede (como VCN, gateway de internet, gateway NAT, tabelas de rotas, listas de segurança, uma sub-rede regional para nós de trabalho e outra sub-rede regional para balanceadores de carga), com nomes gerados automaticamente no formatooke-<resource-type>-quick-<cluster-name>-<creation-date>
o cluster, com o nome que você especificou o pool de nós, chamado pool1 nós de trabalho, com nomes gerados automaticamente no formato **oke-c<part-of-cluster-OCID>-n<part-of-node-pool-OCID>-s<part-of-subnet-OCID>-<slot>**

Não altere os nomes de recursos que o Container Engine for Kubernetes gerou automaticamente. 

Observe que, se o cluster não for criado com sucesso por algum motivo (por exemplo, se você tiver permissões insuficientes ou se tiver excedido o limite do cluster para o aluguel), quaisquer recursos de rede criados durante o processo de criação do cluster não serão excluídos automaticamente. Você terá que excluir manualmente esses recursos de rede não utilizados.

Clique em Fechar para retornar ao Console.

Inicialmente, o novo cluster aparece no Console com o status de Criação. Quando o cluster é criado, ele tem um status de Ativo.

O Container Engine for Kubernetes também cria um arquivo de configuração do Kubernetes kubeconfig que você usa para acessar o cluster usando o kubectl.
 
# Criando um Vault

# Criando um Certificado CA

O Service Mesh demanda a criação de um certificado do tipo CA (Certificate Authority) para associar seus certificados para autenticação (interna e externa - TLS ou mTLS).

Clique no menu hambúrger e selecione a opção "Identity & Security" e depois "Certificates" conforme abaixo:

![certiicate-ca-creation.png](https://github.com/hoshikawa2/repo-image/blob/master/certiicate-ca-creation.png?raw=true)

Selecione então a opção "Certificate Authorities"

![certificate-ca-creation-2.png](https://github.com/hoshikawa2/repo-image/blob/master/certificate-ca-creation-2.png?raw=true)

Clique então no botão "Create Certificate" conforme abaixo:

![certificates-ca-creation3.png](https://github.com/hoshikawa2/repo-image/blob/master/certificates-ca-creation3.png?raw=true)

Preencha os campos da tela com:

    Compartment: O nome do compartimento em que deseja armazenar os certificados
    Root Certificate Authority: Esta opção irá criar internamente de forma automatizada seu certificado
    Nome: O nome do CA
    Descrição: A descrição do CA

![ca-01.png](https://github.com/hoshikawa2/repo-image/blob/master/ca-01.png?raw=true)

Clique em "Next" e preencha o campo "Common Name" como:

    helloworldtls

![ca-02.png](https://github.com/hoshikawa2/repo-image/blob/master/ca-02.png?raw=true)

Clique em "Next" e preencha:

    Not Valid Before: Com uma data posterior a data atual
    Not Valid After: Com uma data que não ultrapasse mais de 2 meses
    Vault: Selecione o Vault criado anteriormente
    Key: Selecione sua chave criada anteriormente no Vault
    Signing Algorithm: SHA256_WITH_RSA

![ca-05.png](https://github.com/hoshikawa2/repo-image/blob/master/ca-05.png?raw=true)

Aceite os valores oferecidos nesta tela

![ca-06.png](https://github.com/hoshikawa2/repo-image/blob/master/ca-06.png?raw=true)

E clique em "Next". Nesta próxima tela, clique na opção "Skip Revocation" e clique em "Next" novamente para ir à tela de cnofirmação final:

![ca-07.png](https://github.com/hoshikawa2/repo-image/blob/master/ca-07.png?raw=true)

Na tela final, clique no botão "Create Certificate Authority"

![ca-08.png](https://github.com/hoshikawa2/repo-image/blob/master/ca-08.png?raw=true)

Pronto! Você finalizou o processo de criação do "Certificado de Autoridade".




# Criando o Service Mesh no OKE

### Pré-Requisitos

Instale o seguinte em um laptop, computador pessoal ou máquina virtual que gerencie seu aplicativo Kubernetes.

Oracle OCI CLI 3.8.0 ou posterior. Consulte Trabalhando com a CLI da OCI para obter instruções de instalação.

A ferramenta CLI do Kubernetes kubectl. Consulte Instalar Ferramentas Kubernetes para obter detalhes.

Ensure you can access the OKE cluster from the command line using kubectl by setting up the kube-config file. For detailed steps, see: Setting Up Local Access to Clusters

#### Certifique-se de que criou as políticas de acesso para o Service Mesh

https://docs.oracle.com/en-us/iaas/Content/service-mesh/iam-policy-reference.htm#policies

#### Certifique-se de que criou as políticas de acesso para os certificados

https://docs.oracle.com/en-us/iaas/Content/certificates/managing-certificates.htm#certs_required_iam_policy

#### Certifique-se de que criou as políticas de acesso para o Vault

https://docs.oracle.com/en-us/iaas/Content/KeyManagement/Tasks/managingvaults.htm#permissions

### Instale o Operador de Serviço OCI para Kubernetes para Service Mesh

O Operador de Serviços OCI para Kubernetes facilita a criação, o gerenciamento e a conexão a recursos OCI a partir de um ambiente Kubernetes. 

Os usuários do Kubernetes podem simplesmente instalar o Operador de Serviços OCI para Kubernetes e executar ações nos recursos OCI usando a API do Kubernetes. 

O Operador de Serviço OCI para Kubernetes elimina a necessidade de usar a CLI OCI ou outras ferramentas de desenvolvedor OCI para interagir com uma API de serviço.

O Operador de Serviço OCI para Kubernetes é baseado no Operator Framework, um kit de ferramentas de código aberto usado para gerenciar Operadores. 

Ele usa a biblioteca de tempo de execução do controlador, que fornece APIs e abstrações de alto nível para escrever lógica operacional e também fornece ferramentas para andaimes e geração de código para Operadores.

Para obter mais informações sobre o SDK do Operador, consulte o site do Operator Framework (https://operatorframework.io).

### Instale o SDK do Operador e o OLM

Instale o SDK do Operador na sua máquina local usando as seguintes etapas.

#### Instale o SDK do Operador

Vá para a página de instalação do Operator SDK e siga as instruções de instalação do seu sistema operacional.

Instale o Gerenciador de Ciclo de Vida do Operador (OLM). 

O OLM ajuda os usuários a instalar, atualizar e gerenciar o ciclo de vida dos aplicativos nativos do Kubernetes (Operadores) e seus serviços associados em execução em clusters. Use o seguinte comando para instalar:

    operator-sdk olm install --version 0.20.0

**Nota**

O acesso local ao seu cluster Kubernetes deve ser configurado na sua máquina antes que você possa executar esta etapa.
Verifique sua instalação do OLM primeiro verificando todas as Definições de Recursos do Cliente (CRDs) necessárias no cluster. 

Execute o seguinte comando.

    operator-sdk olm status

O comando produz uma saída semelhante à seguinte:

![tut-03.png](https://github.com/hoshikawa2/repo-image/blob/master/tut-03.png?raw=true)


# Implantando um contêiner e um serviço de exemplo
Para o próximo passo, você necessitará da linha de comando **kubectl** conforme explicado na etapa anterior. Crie um arquivo de configuração YAML como abaixo e execute em seu terminal.

    apiVersion: v1
    kind: Service
    metadata:
      name: helloworld-service-tls
      namespace: default
      labels: 
        app: helloworld-tls
    spec:
      ports:
      - protocol: TCP
        port: 8080
        targetPort: 8080
      selector:
    #    servicemesh.oci.oracle.com/ingress-gateway-deployment: redis-ingress-gateway-binding
        app: helloworld-tls
      type: ClusterIP
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: helloworld-tls
      name: helloworld-tls
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: helloworld-tls
      template:
        metadata:
          labels:
            app: helloworld-tls
        spec:
          containers:
          - image: gcr.io/google-samples/node-hello:1.0
            name: helloworld
            ports:
            - containerPort: 8080
    ---



# Implantando um Service Mesh

Com seu **kubectl** devidamente instalado, vamos configurar agora o arquivo YAML para criar seu Service Mesh.
Para isto, você precisa alterar o "id" na seção "certificateAuthorities" com o OCID de seu certificado de autoridade criado anteriormente.



    ---
    kind: Mesh
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    metadata:
      name: helloworldtls
      namespace: default
    spec:
      compartmentId:     ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq
      certificateAuthorities:
        - id:     ocid1.certificateauthority.oc1.iad.amaaaaaaihuwreya754t5qtlusnon6q6lsi6is3hk62gafn72xy54twe2nia
      mtls:
        minimum: STRICT
    #    minimum: PERMISSIVE
    #    minimum: DISABLED

![service-mesh-details-2.png](https://github.com/hoshikawa2/repo-image/blob/master/service-mesh-details-2.png?raw=true)


# Criando um Virtual Service

    ---
    kind: VirtualService
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    metadata:
      name: ms-helloworldtls
      namespace: default
    spec:
      mesh:
        ref:
          name: helloworldtls
    
      defaultRoutingPolicy:
        type: UNIFORM
      mtls:
    #    mode: DISABLED
    #    mode: PERMISSIVE
        mode: STRICT
      compartmentId:     ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq
      hosts:
        - helloworld-service-tls:8080
    ---
    kind: VirtualDeployment
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    metadata:
      name: ms-helloworldtls
      namespace: default
    spec:
      virtualService:
        ref:
          name: ms-helloworldtls
      compartmentId:     ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq
      listener:
        - port: 8080
          protocol: HTTP
      accessLogging:
        isEnabled: true
      serviceDiscovery:
        type: DNS
        hostname: helloworld-service-tls
    ---
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    kind: VirtualServiceRouteTable
    metadata:
      name: ms-helloworld-route-table-tls
      namespace: default
    spec:
      compartmentId:     ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq
      virtualService:
        ref:
          name: ms-helloworldtls
      routeRules:
        - httpRoute:
            destinations:
              - virtualDeployment:
                  ref:
                    name: ms-helloworldtls
                weight: 100
    ---

![virtual-service-create.png](https://github.com/hoshikawa2/repo-image/blob/master/virtual-service-create.png?raw=true)

![virtual-service-details.png](https://github.com/hoshikawa2/repo-image/blob/master/virtual-service-details.png?raw=true)

![virtual-deployment-listerner.png](https://github.com/hoshikawa2/repo-image/blob/master/virtual-deployment-listerner.png?raw=true)

![virtual-service-route-2.png](https://github.com/hoshikawa2/repo-image/blob/master/virtual-service-route-2.png?raw=true)

![virtual-service-host2.png](https://github.com/hoshikawa2/repo-image/blob/master/virtual-service-host2.png?raw=true)


# Criando um Ingress

    ---
    kind: IngressGateway
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    metadata:
      name: helloworld-ingress-gateway-tls
      namespace: default
    spec:
      compartmentId:     ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq
      mesh:
        ref:
          name: helloworldtls
      hosts:
        - name: helloworldtls
          hostnames:
            - "helloworldtls"
    #        - "helloworldtls:8082"
    #        - "*"
          listeners:
            - port: 8080
              protocol: HTTP
              tls:
                mode: MUTUAL_TLS
                serverCertificate:
                  ociTlsCertificate:
                    #certificateId:     ocid1.certificate.oc1.iad.amaaaaaaihuwreyabbu3g4patim63tztwnnoljusv553puqos5lry5xitkca
                    certificateId: ocid1.certificate.oc1.iad.amaaaaaaihuwreyai5memoysx7igko3bmzkhkriolslqizicsvr5agage6oa #demo-ingress
                        #certificateId:     ocid1.certificate.oc1.iad.amaaaaaaihuwreyaa4iivhbwb6n5e3nrayykymocxesv5t524qsg4z2llfgq     #mesh-8bf2d437-2162-4612-b708-5332a2d5aacc
                clientValidation:
                  trustedCaBundle:
                    ociCaBundle:
                      caBundleId:     ocid1.cabundle.oc1.iad.amaaaaaaihuwreyafexaxy5kwutz2jzahg3hhzl7iaxgd5ek4nrgalglz7yq
    #              subjectAlternateNames:
    #                - authorized1.client
    #                - authorized2.client
    #            mode: TLS
    #            mode: DISABLED
      accessLogging:
        isEnabled: true
    ---
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    kind: IngressGatewayRouteTable
    metadata:
      name: helloworld-ingress-gateway-route-table-tls
      namespace: default
    spec:
      compartmentId: ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq
      name: helloworld-ingress-gateway-route-table-tls
      ingressGateway:
        ref:
          name: helloworld-ingress-gateway-tls
      routeRules:
        - httpRoute:
            ingressGatewayHost:
              name: helloworldtls
            destinations:
              - virtualService:
                  ref:
                    name: ms-helloworldtls
    ---


# Criando o certificado de Ingress

# Criando o certificado do Client

# Criando o certificado Bundle 

# Criando a política de acesso para o Ingress

    ---
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    kind: AccessPolicy
    metadata:
      name: helloworld-access-policy-tls      # Access Policy name
      namespace: default
    spec:
      compartmentId:     ocid1.compartment.oc1..aaaaaaaajp2gjl5ki2mhfnybw4foi2b7apv4khhyrkcjior23jsxbr47yvuq
      name: helloworld-ap-tls     # Access Policy name inside the mesh
      description: This Access Policy
      mesh:
        ref:
          name: helloworldtls
      rules:
        - action: ALLOW
          source:
            allVirtualServices: {}
          destination:
            allVirtualServices: {}
        - action: ALLOW
          source:
            ingressGateway:
              ref:
                name: helloworld-ingress-gateway-tls
          destination:
            allVirtualServices: {}
        - action: ALLOW
          source:
            virtualService:
              ref:
                name: ms-helloworldtls
          destination:
            externalService:
              httpExternalService:
                hostnames: ["helloworldtls"]
                ports: [443]
    ---


# Criando o Binding entre Virtual Service e Ingress

    ---
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    kind: VirtualDeploymentBinding
    metadata:
      name: ms-helloworld-binding-tls
      namespace: default
      annotations:
        servicemesh.oci.oracle.com/proxy-log-level: debug
    spec:
      virtualDeployment:
        id: >-
              ocid1.meshvirtualdeployment.oc1.iad.amaaaaaaihuwreyam2rdw6x7w7lahk3nw2t5ovsl35sump44xpfxbetjthlq
      target:
        service:
          ref:
            name: helloworld-service-tls
            namespace: default
    ---
    apiVersion: servicemesh.oci.oracle.com/v1beta1
    kind: IngressGatewayDeployment
    metadata:
      name: helloworld-ingress-gateway-binding-tls
      namespace: default
      annotations:
        servicemesh.oci.oracle.com/proxy-log-level: debug
    spec:
      ingressGateway:
        id: >-
      ocid1.meshingressgateway.oc1.iad.amaaaaaaihuwreyapjrbbojrhsmetnydun6alfqvllyhzi2yfosolf3memza
      deployment:
        autoscaling:
          minPods: 1
          maxPods: 1
        labels:
              app: helloworld-tls
      ports:
        - protocol: TCP
          serviceport: 443
          port: 8080
      service:
        type: LoadBalancer

# Testando o serviço de contêiner com autenticação mTLS

    curl -vvv -i -k --cacert cacert.pem \
         --key demo-client-private.pem \
         --cert demo-client-certificate.pem \
        https://helloworldtls


![curl-mtls-service-mesh-result.png](https://github.com/hoshikawa2/repo-image/blob/master/curl-mtls-service-mesh-result.png?raw=true)

# Referências

#### Começando com Service Mesh
https://docs.oracle.com/en-us/iaas/Content/service-mesh/ovr-getting-started.htm

#### Using the Console to create a Cluster with Default Settings in the 'Quick Create' workflow
https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm

#### Tutorial
https://docs.oracle.com/en-us/iaas/Content/service-mesh/ovr-getting-started.htm

#### Documentação Detalhada
https://docs.oracle.com/en-us/iaas/Content/service-mesh/virt-svc-create.htm

#### Debug
https://docs.oracle.com/en-us/iaas/Content/service-mesh/kube-virt-deploy.htm
