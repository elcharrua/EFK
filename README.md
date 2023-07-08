**README.MD**

**elasticsearch.yaml**
Este arquivo contém as definições para implantar o Elasticsearch no Kubernetes. Ele consiste nos seguintes recursos:

ServiceAccount: O recurso ServiceAccount chamado tiller é criado no namespace elk. Ele é usado para autenticação e autorização do Tiller, que é o servidor de controle do Helm.

ClusterRoleBinding: O ClusterRoleBinding chamado tiller associa a conta de serviço tiller ao papel cluster-admin no grupo rbac.authorization.k8s.io, concedendo permissões de administrador de cluster.

Service: O Service chamado elasticsearch é criado com o nome do aplicativo elasticsearch. Ele usa seletores para direcionar o tráfego para as instâncias corretas do Elasticsearch. O IP do cluster é definido como "None" para que o serviço seja acessível somente de dentro do cluster. O Elasticsearch expõe as portas 9200 (rest) e 9300 (inter-node) para comunicação.

Job: O Job chamado generate-certs é criado para gerar certificados para comunicação segura com o Elasticsearch. Ele usa um contêiner com a imagem docker.elastic.co/elasticsearch/elasticsearch:7.13.2 e executa comandos para gerar os certificados.

StatefulSet: O StatefulSet chamado es-cluster é criado para implantar o Elasticsearch em um conjunto de réplicas. Ele define a quantidade de réplicas como 3 e usa um conjunto de volumes reivindicados para armazenar os dados do Elasticsearch. Também configura os recursos de CPU e memória para cada réplica e define várias variáveis de ambiente para configurar o cluster Elasticsearch.

README.MD
Este arquivo README.MD descreve os recursos dos arquivos de configuração YAML fornecidos e como eles funcionam juntos para criar um ambiente de monitoramento de logs com Elasticsearch, Fluentd e Kibana.

elasticsearch.yaml
Este arquivo contém as definições para implantar o Elasticsearch no Kubernetes. Ele consiste nos seguintes recursos:

ServiceAccount: O recurso ServiceAccount chamado tiller é criado no namespace elk. Ele é usado para autenticação e autorização do Tiller, que é o servidor de controle do Helm.

ClusterRoleBinding: O ClusterRoleBinding chamado tiller associa a conta de serviço tiller ao papel cluster-admin no grupo rbac.authorization.k8s.io, concedendo permissões de administrador de cluster.

Service: O Service chamado elasticsearch é criado com o nome do aplicativo elasticsearch. Ele usa seletores para direcionar o tráfego para as instâncias corretas do Elasticsearch. O IP do cluster é definido como "None" para que o serviço seja acessível somente de dentro do cluster. O Elasticsearch expõe as portas 9200 (rest) e 9300 (inter-node) para comunicação.

Job: O Job chamado generate-certs é criado para gerar certificados para comunicação segura com o Elasticsearch. Ele usa um contêiner com a imagem docker.elastic.co/elasticsearch/elasticsearch:7.13.2 e executa comandos para gerar os certificados.

StatefulSet: O StatefulSet chamado es-cluster é criado para implantar o Elasticsearch em um conjunto de réplicas. Ele define a quantidade de réplicas como 3 e usa um conjunto de volumes reivindicados para armazenar os dados do Elasticsearch. Também configura os recursos de CPU e memória para cada réplica e define várias variáveis de ambiente para configurar o cluster Elasticsearch.

**fluentd.yaml**
Este arquivo contém as definições para implantar o Fluentd no Kubernetes. Ele consiste nos seguintes recursos:

ConfigMap: O ConfigMap chamado fluentd-config é criado no namespace elk e contém a configuração do Fluentd. Ele define várias seções para coletar, analisar e encaminhar logs de contêineres do Kubernetes para o Elasticsearch.

ServiceAccount: O recurso ServiceAccount chamado fluentd é criado no namespace elk. Ele é usado para autenticação e autorização do Fluentd.

ClusterRole: O ClusterRole chamado fluentd é criado no namespace elk e define as permissões para o Fluentd acessar recursos do Kubernetes, como pods e namespaces.

ClusterRoleBinding: O ClusterRoleBinding chamado fluentd associa a conta de serviço fluentd ao papel fluentd, concedendo as permissões definidas pelo ClusterRole.

DaemonSet: O DaemonSet chamado fluentd é criado para implantar o Fluentd em todos os nós do cluster Kubernetes. Ele usa a imagem fluent/fluentd-kubernetes-daemonset:v1.12.4-debian-elasticsearch7-1.1 e monta vários volumes para coletar e encaminhar logs.

kibana.yaml
Este arquivo contém as definições para implantar o Kibana no Kubernetes. Ele consiste nos seguintes recursos:

Deployment: O Deployment chamado kibana é criado para implantar o Kibana. Ele usa a imagem docker.elastic.co/kibana/kibana:7.13.2 e define variáveis de ambiente para configurar a URL do Elasticsearch, bem como as credenciais de autenticação. Também especifica recursos de CPU e memória para o contêiner.
Service: O Service chamado kibana é criado para expor o Kibana internamente no cluster Kubernetes. Ele define a porta 5601 para acessar a interface do usuário do Kibana.
Ingress: O Ingress chamado logs-ingress é criado para expor o Kibana externamente usando um controlador de ingresso baseado em Nginx. Ele redireciona o tráfego com base no host para o serviço kibana na porta 5601.
Esses recursos trabalham juntos para criar um ambiente de monitoramento de logs. O Elasticsearch é implantado para armazenar e pesquisar logs, o Fluentd é implantado para coletar e encaminhar logs para o Elasticsearch, e o Kibana é implantado como uma interface de usuário para visualizar e analisar os logs armazenados no Elasticsearch.
Este arquivo contém as definições para implantar o Fluentd no Kubernetes. Ele consiste nos seguintes recursos:

ConfigMap: O ConfigMap chamado fluentd-config é criado no namespace elk e contém a configuração do Fluentd. Ele define várias seções para coletar, analisar e encaminhar logs de contêineres do Kubernetes para o Elasticsearch.

ServiceAccount: O recurso ServiceAccount chamado fluentd é criado no namespace elk. Ele é usado para autenticação e autorização do Fluentd.

ClusterRole: O ClusterRole chamado fluentd é criado no namespace elk e define as permissões para o Fluentd acessar recursos do Kubernetes, como pods e namespaces.

ClusterRoleBinding: O ClusterRoleBinding chamado fluentd associa a conta de serviço fluentd ao papel fluentd, concedendo as permissões definidas pelo ClusterRole.

DaemonSet: O DaemonSet chamado fluentd é criado para implantar o Fluentd em todos os nós do cluster Kubernetes. Ele usa a imagem fluent/fluentd-kubernetes-daemonset:v1.12.4-debian-elasticsearch7-1.1 e monta vários volumes para coletar e encaminhar logs.

**kibana.yaml**
Este arquivo contém as definições para implantar o Kibana no Kubernetes. Ele consiste nos seguintes recursos:

Deployment: O Deployment chamado kibana é criado para implantar o Kibana. Ele usa a imagem docker.elastic.co/kibana/kibana:7.13.2 e define variáveis de ambiente para configurar a URL do Elasticsearch, bem como as credenciais de autenticação. Também especifica recursos de CPU e memória para o contêiner.
Service: O Service chamado kibana é criado para expor o Kibana internamente no cluster Kubernetes. Ele define a porta 5601 para acessar a interface do usuário do Kibana.
Ingress: O Ingress chamado logs-ingress é criado para expor o Kibana externamente usando um controlador de ingresso baseado em Nginx. Ele redireciona o tráfego com base no host para o serviço kibana na porta 5601.
Esses recursos trabalham juntos para criar um ambiente de monitoramento de logs. O Elasticsearch é implantado para armazenar e pesquisar logs, o Fluentd é implantado para coletar e encaminhar logs para o Elasticsearch, e o Kibana é implantado como uma interface de usuário para visualizar e analisar os logs armazenados no Elasticsearch.
