#!/bin/bash
# Script para criar estrutura de teste ArgoCD para gerenciamento multi-cluster

# Criação da estrutura de diretórios principal
echo "Criando estrutura de diretórios principal..."
mkdir -p argocd-multicluster-test
cd argocd-multicluster-test

# Criar todos os diretórios necessários de uma vez
echo "Criando todos os diretórios necessários..."
mkdir -p argocd-config/overlays/{dev,staging,prod}
mkdir -p argocd-config/base
mkdir -p cluster-bootstrap/{dev,staging,prod}
mkdir -p applications/{base,overlays/{dev,staging,prod},appsets}
mkdir -p platform/{ingress-nginx,cert-manager,monitoring,logging}/{base,overlays/{dev,staging,prod}}
mkdir -p workloads/templates
mkdir -p workloads/apps/{api-service,frontend,database,message-queue}/{base,overlays/{dev,staging,prod}}
mkdir -p tests

# Criar o README.md
echo "Criando README.md..."
cat > README.md << 'EOF'
# Teste de ArgoCD Multi-Cluster para EKS

## Visão Geral
Este teste avalia sua capacidade de configurar e gerenciar uma estrutura GitOps com ArgoCD para múltiplos clusters EKS em diferentes contas AWS.

## Requisitos
- Conhecimento de Kubernetes e EKS
- Experiência com ArgoCD e princípios GitOps
- Familiaridade com Kustomize para gerenciamento de variações entre ambientes
- Compreensão de estratégias de implantação em múltiplos clusters

## Tarefas

### 1. Configuração do ArgoCD
Configure o ArgoCD para gerenciar múltiplos clusters EKS com:
- Uma instalação de ArgoCD centralizada no cluster de ferramentas
- Configuração de acesso seguro a todos os clusters gerenciados
- Implementação de autenticação OIDC com AWS IAM

### 2. Estrutura de Aplicações
Implemente uma estrutura de aplicações que:
- Suporte implantações em múltiplos ambientes (dev, staging, prod)
- Utilize Kustomize para gerenciar diferenças entre ambientes
- Configure promoção automatizada entre ambientes

### 3. Componentes de Plataforma
Configure componentes de plataforma para todos os clusters:
- Controladores de Ingress
- Gerenciamento de certificados
- Monitoramento e observabilidade
- Logging centralizado

### 4. Segurança e Isolamento
Implemente práticas de segurança como:
- Políticas de rede para isolamento
- RBAC para acesso granular
- Integração com Secrets Management (AWS Secrets Manager ou Vault)

## Entrega
- Complete todos os arquivos YAML/Kustomize conforme necessário
- Documente sua abordagem e decisões em um arquivo SOLUTION.md
- Inclua instruções de como um administrador configuraria a integração com EKS
- Adicione detalhes sobre como promover aplicações entre ambientes
EOF

# Criar arquivos de configuração do ArgoCD e aplicações
echo "Criando arquivos de configuração..."

# Aqui continuaríamos com a criação de todos os outros arquivos...
# Para simplificar e evitar problemas, vamos criar apenas alguns arquivos essenciais

# Configuração base do ArgoCD
cat > argocd-config/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- argocd-install.yaml
- argocd-cm.yaml
- argocd-rbac-cm.yaml
EOF

# Arquivos de exemplo para o projeto
cat > applications/base/project.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: main-applications
  namespace: argocd
spec:
  description: "Projeto principal para aplicações de negócio"
  sourceRepos:
  - "https://github.com/organization/application-repo.git"
  destinations:
  - namespace: "*"
    server: https://kubernetes.dev.example.com
  - namespace: "*"
    server: https://kubernetes.staging.example.com
  - namespace: "*"
    server: https://kubernetes.prod.example.com
EOF

# Aplicação de exemplo
cat > workloads/apps/api-service/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  labels:
    app: api-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: api
        image: api-service:1.0.0
        ports:
        - containerPort: 8080
EOF

# Guia de implementação
cat > IMPLEMENTATION.md << 'EOF'
# Guia de Implementação - ArgoCD Multi-Cluster

## Pré-requisitos
- Kubectl instalado e configurado
- Acesso administrativo aos clusters EKS
- Git configurado

## Passos para Implementação

1. Instalar ArgoCD no cluster principal:
   ```bash
   kubectl apply -k argocd-config/overlays/dev

# Criar a configuração base do ArgoCD
echo "Criando configuração base do ArgoCD..."
cat > argocd-config/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- argocd-install.yaml
- argocd-cm.yaml
- argocd-rbac-cm.yaml
- argocd-secret.yaml
- clusters/
EOF

cat > argocd-config/base/argocd-install.yaml << 'EOF'
# Esta é uma versão simplificada para o teste
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd
  namespace: argocd
spec:
  server:
    route:
      enabled: true
    ingress:
      enabled: false
  dex:
    enabled: true
    openShiftOAuth: false
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 250m
        memory: 128Mi
  ha:
    enabled: true
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 250m
        memory: 128Mi
  rbac:
    defaultPolicy: 'role:readonly'
    policy: |
      g, system:cluster-admins, role:admin
      g, sre-team, role:admin
    scopes: '[groups]'
  repositories:
    - name: app-repo
      url: https://github.com/organization/application-repo.git
    - name: platform-repo
      url: https://github.com/organization/platform-repo.git
  sso:
    provider: dex
    dex:
      config: |
        connectors:
          - type: github
            id: github
            name: GitHub
            config:
              clientID: $GITHUB_CLIENT_ID
              clientSecret: $GITHUB_CLIENT_SECRET
              orgs:
              - name: your-github-org
  version: v2.7.4
EOF

cat > argocd-config/base/argocd-cm.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  # Configurações de URL do servidor ArgoCD
  url: https://argocd.example.com

  # Configurações de repositórios
  repositories: |
    - type: git
      url: https://github.com/organization/application-repo
      name: application-repo
    - type: git
      url: https://github.com/organization/platform-repo
      name: platform-repo

  # Configuração de cluster - formato admitido pelo ArgoCD
  kustomize.buildOptions: "--enable-helm"

  # Recurso personalizado para monitorar status
  resource.customizations: |
    argoproj.io/Application:
      health.lua: |
        health_status = {}
        if obj.status ~= nil then
          if obj.status.health ~= nil then
            health_status.status = obj.status.health.status
            if health_status.status == nil then
              health_status.status = "Progressing"
            end
            health_status.message = obj.status.health.message
          end
        end
        return health_status
EOF

cat > argocd-config/base/argocd-rbac-cm.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-rbac-cm
    app.kubernetes.io/part-of: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    # Políticas RBAC do ArgoCD
    p, role:org-admin, applications, *, */*, allow
    p, role:org-admin, clusters, *, *, allow
    p, role:org-admin, repositories, *, *, allow
    p, role:org-admin, projects, *, *, allow

    # Devs só podem ver e sincronizar aplicações nos ambientes dev
    p, role:dev, applications, get, dev-cluster/*, allow
    p, role:dev, applications, sync, dev-cluster/*, allow

    # SREs podem gerenciar todos os ambientes
    p, role:sre, applications, *, */*, allow
    p, role:sre, clusters, get, *, allow
    
    # Mapeamento de grupos
    g, sre-team, role:sre
    g, dev-team, role:dev
    g, system:cluster-admins, role:org-admin
EOF

cat > argocd-config/base/argocd-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: argocd-secret
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-secret
    app.kubernetes.io/part-of: argocd
type: Opaque
stringData:
  # Esses valores seriam definidos usando um Secret Management em um ambiente real
  admin.password: "$2a$10$someHashedPasswordForTesting"
  admin.passwordMtime: "2023-01-01T00:00:00Z"
  server.secretkey: "SomeRandomGeneratedKey"
  dex.github.clientSecret: "GitHubClientSecretWouldGoHere"
EOF

# Criar overlay para ambiente dev
echo "Criando overlay ArgoCD para ambiente dev..."
cat > argocd-config/overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: argocd

patchesStrategicMerge:
- argocd-cm-patch.yaml
- argocd-rbac-cm-patch.yaml

resources:
- dev-cluster.yaml
EOF

cat > argocd-config/overlays/dev/argocd-cm-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd-dev.example.com
  
  # Ajustes específicos para ambiente dev
  resource.exclusions: |
    - apiGroups: [""]
      kinds: ["ConfigMap"]
      clusters: ["dev-cluster"]
      names: ["dev-only-config"]
EOF

cat > argocd-config/overlays/dev/argocd-rbac-cm-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    # Políticas específicas para o ambiente dev
    p, role:dev, applications, *, dev-cluster/*, allow
    p, role:dev, logs, get, dev-cluster/*, allow
    
    # Dev leads podem gerenciar projetos no ambiente dev
    p, role:dev-lead, applications, *, dev-cluster/*, allow
    p, role:dev-lead, projects, *, dev-cluster/*, allow
    
    # Mapeamento de grupos
    g, dev-leads, role:dev-lead
EOF

cat > argocd-config/overlays/dev/dev-cluster.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: dev-cluster-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: dev-cluster
  server: https://kubernetes.dev.example.com
  config: |
    {
      "awsAuthConfig": {
        "clusterName": "dev-eks-cluster",
        "roleARN": "arn:aws:iam::111122223333:role/ArgoCD-EKS-Access"
      },
      "tlsClientConfig": {
        "insecure": false
      }
    }
EOF

# Criar overlay para ambiente de produção
echo "Criando overlay ArgoCD para ambiente de produção..."
cat > argocd-config/overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: argocd

patchesStrategicMerge:
- argocd-cm-patch.yaml
- argocd-rbac-cm-patch.yaml

resources:
- prod-cluster.yaml
EOF

cat > argocd-config/overlays/prod/argocd-cm-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.example.com
  
  # Configurações específicas para produção
  statusbadge.enabled: "false"
  resource.exclusions: |
    - apiGroups: [""]
      kinds: ["Secret"]
      clusters: ["prod-cluster"]
      names: ["prod-sensitive-*"]
  
  # Configurações de segurança reforçadas para produção
  application.instanceLabelKey: argocd.argoproj.io/instance
EOF

cat > argocd-config/overlays/prod/argocd-rbac-cm-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    # Políticas restritas para produção
    # Somente SREs e admins podem fazer alterações em produção
    p, role:sre, applications, *, prod-cluster/*, allow
    p, role:prod-approver, applications, action/approve, prod-cluster/*, allow
    
    # Dev leads só podem ver produção
    p, role:dev-lead, applications, get, prod-cluster/*, allow
    
    # Requer aprovação para sincronização em produção
    p, role:prod-deployer, applications, sync, prod-cluster/*, allow
    
    # Mapeamento de grupos
    g, prod-approvers, role:prod-approver
    g, prod-deployers, role:prod-deployer
EOF

cat > argocd-config/overlays/prod/prod-cluster.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: prod-cluster-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: prod-cluster
  server: https://kubernetes.prod.example.com
  config: |
    {
      "awsAuthConfig": {
        "clusterName": "prod-eks-cluster",
        "roleARN": "arn:aws:iam::777788889999:role/ArgoCD-EKS-Access"
      },
      "tlsClientConfig": {
        "insecure": false
      }
    }
EOF

# Criar configuração de bootstrap para os clusters
echo "Criando configurações de bootstrap para os clusters..."

# Bootstrap para dev
cat > cluster-bootstrap/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- namespace.yaml
- argocd-application-set.yaml
EOF

cat > cluster-bootstrap/dev/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
---
apiVersion: v1
kind: Namespace
metadata:
  name: logging
EOF

cat > cluster-bootstrap/dev/argocd-application-set.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-bootstrap-dev
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - name: ingress-nginx
        namespace: ingress-nginx
      - name: cert-manager
        namespace: cert-manager
      - name: monitoring
        namespace: monitoring
      - name: logging
        namespace: logging
  template:
    metadata:
      name: '{{name}}-dev'
    spec:
      project: platform
      source:
        repoURL: https://github.com/organization/platform-repo.git
        targetRevision: HEAD
        path: platform/{{name}}/overlays/dev
      destination:
        server: https://kubernetes.dev.example.com
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
EOF

# Bootstrap para produção
cat > cluster-bootstrap/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- namespace.yaml
- argocd-application-set.yaml
EOF

cat > cluster-bootstrap/prod/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
---
apiVersion: v1
kind: Namespace
metadata:
  name: logging
---
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
EOF

cat > cluster-bootstrap/prod/argocd-application-set.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-bootstrap-prod
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - name: ingress-nginx
        namespace: ingress-nginx
      - name: cert-manager
        namespace: cert-manager
      - name: monitoring
        namespace: monitoring
      - name: logging
        namespace: logging
  template:
    metadata:
      name: '{{name}}-prod'
    spec:
      project: platform
      source:
        repoURL: https://github.com/organization/platform-repo.git
        targetRevision: HEAD
        path: platform/{{name}}/overlays/prod
      destination:
        server: https://kubernetes.prod.example.com
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
      # Estratégia de sincronização conservadora para produção
      syncOptions:
      - Validate=true
      - CreateNamespace=true
      - PruneLast=true
      # Configurar janela de sincronização para manutenção programada
      # syncWindows:
      # - kind: allow
      #   schedule: "0 22 * * *"
      #   duration: 2h
      #   applications:
      #   - '*-prod'
      #   namespaces:
      #   - '*'
      #   clusters:
      #   - prod-cluster
EOF

# Criar configuração do projeto ArgoCD
echo "Criando configuração de projeto ArgoCD..."
cat > applications/base/project.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: main-applications
  namespace: argocd
spec:
  description: "Projeto principal para aplicações de negócio"
  
  # Origem dos repositórios Git confiáveis
  sourceRepos:
  - "https://github.com/organization/application-repo.git"
  
  # Destinos permitidos para implantação
  destinations:
  - namespace: "*"
    server: https://kubernetes.dev.example.com
  - namespace: "*"
    server: https://kubernetes.staging.example.com
  - namespace: "*"
    server: https://kubernetes.prod.example.com
  
  # Tipos de recursos do Kubernetes permitidos
  clusterResourceWhitelist:
  - group: ""
    kind: Namespace
  - group: "networking.k8s.io"
    kind: Ingress
  
  # Recursos permitidos em namespaces
  namespaceResourceWhitelist:
  - group: "*"
    kind: "*"
  
  # Regras de validação para impedir alterações específicas
  roles:
  - name: read-only
    description: Read-only access to the project
    policies:
    - p, proj:main-applications:read-only, applications, get, main-applications/*, allow
    groups:
    - dev-team
  - name: admin
    description: Admin access to the project
    policies:
    - p, proj:main-applications:admin, applications, *, main-applications/*, allow
    groups:
    - sre-team
EOF

cat > applications/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- project.yaml
- application-api.yaml
- application-frontend.yaml
- application-database.yaml
EOF

cat > applications/base/application-api.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: api-service
  namespace: argocd
spec:
  project: main-applications
  source:
    repoURL: https://github.com/organization/application-repo.git
    targetRevision: HEAD
    path: workloads/apps/api-service/base
  destination:
    server: https://kubernetes.dev.example.com
    namespace: api-service
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

cat > applications/overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- application-api-patch.yaml
- application-frontend-patch.yaml
EOF

cat > applications/overlays/dev/application-api-patch.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: api-service
  namespace: argocd
spec:
  source:
    path: workloads/apps/api-service/overlays/dev
  destination:
    server: https://kubernetes.dev.example.com
    namespace: api-service-dev
EOF

# Criar componentes de plataforma
echo "Criando componentes de plataforma..."

# Ingress Nginx
cat > platform/ingress-nginx/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- github.com/kubernetes/ingress-nginx/deploy/static/provider/aws?ref=controller-v1.8.1
EOF

cat > platform/ingress-nginx/overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: ingress-nginx

patchesStrategicMerge:
- deployment-patch.yaml
EOF

cat > platform/ingress-nginx/overlays/dev/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: controller
        resources:
          requests:
            cpu: 100m
            memory: 90Mi
EOF

# Monitoring com Prometheus
cat > platform/monitoring/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- github.com/prometheus-operator/kube-prometheus?ref=release-0.13
EOF

cat > platform/monitoring/overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: monitoring

patchesStrategicMerge:
- prometheus-patch.yaml
- alertmanager-patch.yaml
EOF

cat > platform/monitoring/overlays/prod/prometheus-patch.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus-k8s
  namespace: monitoring
spec:
  replicas: 2
  retention: 30d
  resources:
    requests:
      memory: 1Gi
      cpu: 500m
    limits:
      memory: 2Gi
      cpu: 1000m
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: "gp2"
        resources:
          requests:
            storage: 100Gi
EOF

# Criar aplicações de exemplo
echo "Criando aplicações de exemplo..."

# API Service
cat > workloads/apps/api-service/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml
EOF

cat > workloads/apps/api-service/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  labels:
    app: api-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: api
        image: api-service:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: api-config
              key: db_host
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: db_password
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 200m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
EOF

cat > workloads/apps/api-service/base/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api-service
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
EOF

cat > workloads/apps/api-service/base/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  db_host: "database-service"
  api_mode: "standard"
  log_level: "info"
EOF

cat > workloads/apps/api-service/overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: api-service-dev

patchesStrategicMerge:
- deployment-patch.yaml
- configmap-patch.yaml

resources:
- ingress.yaml
EOF

cat > workloads/apps/api-service/overlays/dev/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: api
        image: api-service:dev
        resources:
          limits:
            cpu: 200m
            memory: 256Mi
          requests:
            cpu: 100m
            memory: 128Mi
EOF

cat > workloads/apps/api-service/overlays/dev/configmap-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  db_host: "database-service.database-dev"
  api_mode: "development"
  log_level: "debug"
EOF

cat > workloads/apps/api-service/overlays/dev/ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-service
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: api-dev.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
EOF

cat > workloads/apps/api-service/overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: api-service

patchesStrategicMerge:
- deployment-patch.yaml
- configmap-patch.yaml

resources:
- ingress.yaml
- hpa.yaml
- pdb.yaml
EOF

cat > workloads/apps/api-service/overlays/prod/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  replicas: 3
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
    spec:
      containers:
      - name: api
        image: api-service:prod
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 500m
            memory: 512Mi
        env:
        - name: ENVIRONMENT
          value: "production"
      nodeSelector:
        workload-type: app
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - api-service
              topologyKey: kubernetes.io/hostname
EOF

cat > workloads/apps/api-service/overlays/prod/hpa.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-service
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-service
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF

# Continuar criando a estrutura do ArgoCD

# PodDisruptionBudget para a API Service em produção
cat > workloads/apps/api-service/overlays/prod/pdb.yaml << 'EOF'
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-service
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: api-service
EOF

# Ingress para a API Service em produção
cat > workloads/apps/api-service/overlays/prod/ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-service
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
EOF

# Configuração do ConfigMap da API Service em produção
cat > workloads/apps/api-service/overlays/prod/configmap-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  db_host: "database-service.database-prod.svc.cluster.local"
  api_mode: "production"
  log_level: "warn"
  metrics_enabled: "true"
EOF

# Frontend application
mkdir -p workloads/apps/frontend/base
cat > workloads/apps/frontend/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml
EOF

cat > workloads/apps/frontend/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: frontend:1.0.0
        ports:
        - containerPort: 80
        env:
        - name: API_URL
          valueFrom:
            configMapKeyRef:
              name: frontend-config
              key: api_url
        resources:
          limits:
            cpu: 300m
            memory: 256Mi
          requests:
            cpu: 100m
            memory: 128Mi
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
EOF

cat > workloads/apps/frontend/base/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

cat > workloads/apps/frontend/base/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  api_url: "http://api-service"
  features_enabled: "base"
EOF

# Frontend overlays para desenvolvimento
mkdir -p workloads/apps/frontend/overlays/dev
cat > workloads/apps/frontend/overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: frontend-dev

patchesStrategicMerge:
- deployment-patch.yaml
- configmap-patch.yaml

resources:
- ingress.yaml
EOF

cat > workloads/apps/frontend/overlays/dev/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: frontend
        image: frontend:dev
        resources:
          limits:
            cpu: 200m
            memory: 128Mi
          requests:
            cpu: 100m
            memory: 64Mi
EOF

cat > workloads/apps/frontend/overlays/dev/configmap-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  api_url: "http://api-service.api-service-dev.svc.cluster.local"
  features_enabled: "development,beta"
EOF

cat > workloads/apps/frontend/overlays/dev/ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: frontend-dev.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
EOF

# Frontend overlays para produção
mkdir -p workloads/apps/frontend/overlays/prod
cat > workloads/apps/frontend/overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

namespace: frontend

patchesStrategicMerge:
- deployment-patch.yaml
- configmap-patch.yaml

resources:
- ingress.yaml
- hpa.yaml
- pdb.yaml
EOF

cat > workloads/apps/frontend/overlays/prod/deployment-patch.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "80"
    spec:
      containers:
      - name: frontend
        image: frontend:prod
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 200m
            memory: 256Mi
        env:
        - name: ENVIRONMENT
          value: "production"
      nodeSelector:
        workload-type: frontend
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - frontend
              topologyKey: kubernetes.io/hostname
EOF

cat > workloads/apps/frontend/overlays/prod/configmap-patch.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  api_url: "https://api.example.com"
  features_enabled: "production"
EOF

cat > workloads/apps/frontend/overlays/prod/ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - www.example.com
    secretName: frontend-tls
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
EOF

cat > workloads/apps/frontend/overlays/prod/hpa.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

cat > workloads/apps/frontend/overlays/prod/pdb.yaml << 'EOF'
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: frontend
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: frontend
EOF


# Criar o diretório faltante para ApplicationSets
mkdir -p applications/appsets

# Agora podemos continuar com a criação dos arquivos
cat > applications/appsets/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- platform-appset.yaml
- workloads-appset.yaml
EOF

cat > applications/appsets/platform-appset.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: platform-components
  namespace: argocd
spec:
  generators:
  - matrix:
      generators:
      - list:
          elements:
          - cluster: dev-cluster
            url: https://kubernetes.dev.example.com
            env: dev
          - cluster: staging-cluster
            url: https://kubernetes.staging.example.com
            env: staging
          - cluster: prod-cluster
            url: https://kubernetes.prod.example.com
            env: prod
      - list:
          elements:
          - name: ingress-nginx
            namespace: ingress-nginx
          - name: cert-manager
            namespace: cert-manager
          - name: monitoring
            namespace: monitoring
          - name: logging
            namespace: logging
  template:
    metadata:
      name: '{{name}}-{{env}}'
    spec:
      project: platform
      source:
        repoURL: https://github.com/organization/platform-repo.git
        targetRevision: HEAD
        path: platform/{{name}}/overlays/{{env}}
      destination:
        server: '{{url}}'
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
EOF

cat > applications/appsets/workloads-appset.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: workload-applications
  namespace: argocd
spec:
  generators:
  - matrix:
      generators:
      - list:
          elements:
          - cluster: dev-cluster
            url: https://kubernetes.dev.example.com
            env: dev
          - cluster: staging-cluster
            url: https://kubernetes.staging.example.com
            env: staging
          - cluster: prod-cluster
            url: https://kubernetes.prod.example.com
            env: prod
      - list:
          elements:
          - name: api-service
            namespace: api-service-{{env}}
          - name: frontend
            namespace: frontend-{{env}}
          - name: database
            namespace: database-{{env}}
  template:
    metadata:
      name: '{{name}}-{{env}}'
    spec:
      project: main-applications
      source:
        repoURL: https://github.com/organization/application-repo.git
        targetRevision: HEAD
        path: workloads/apps/{{name}}/overlays/{{env}}
      destination:
        server: '{{url}}'
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
EOF

# Configuração de alertas
mkdir -p platform/monitoring/base/alerts
cat > platform/monitoring/base/alerts/deployment-alerts.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: deployment-alerts
  namespace: monitoring
spec:
  groups:
  - name: deployment
    rules:
    - alert: DeploymentReplicasMismatch
      expr: kube_deployment_spec_replicas{job="kube-state-metrics"} != kube_deployment_status_replicas_available{job="kube-state-metrics"}
      for: 15m
      labels:
        severity: warning
      annotations:
        summary: "Deployment replicas mismatch ({{ $labels.namespace }}/{{ $labels.deployment }})"
        description: "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for 15 minutes."
        
    - alert: DeploymentNotProgressing
      expr: kube_deployment_status_observed_generation{job="kube-state-metrics"} - kube_deployment_metadata_generation{job="kube-state-metrics"} < 0
      for: 15m
      labels:
        severity: critical
      annotations:
        summary: "Deployment not progressing ({{ $labels.namespace }}/{{ $labels.deployment }})"
        description: "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} is not progressing for 15 minutes."
EOF

# Scripts de autograding para o teste
mkdir -p tests
cat > tests/check_argocd_structure.sh << 'EOF'
#!/bin/bash
# Verifica a estrutura básica do ArgoCD

# Verificar se a base do ArgoCD está configurada
if [ -d "argocd-config/base" ] && [ -f "argocd-config/base/argocd-cm.yaml" ]; then
  echo "ArgoCD base configuration found"
else
  echo "Missing ArgoCD base configuration"
  exit 1
fi

# Verificar se existem overlays para os diferentes ambientes
if [ -d "argocd-config/overlays/dev" ] && [ -d "argocd-config/overlays/prod" ]; then
  echo "ArgoCD environment overlays found"
else
  echo "Missing ArgoCD environment overlays"
  exit 1
fi

# Verificar configuração de bootstrap
if [ -d "cluster-bootstrap" ] && [ -f "cluster-bootstrap/dev/argocd-application-set.yaml" ]; then
  echo "Cluster bootstrap configuration found"
else
  echo "Missing cluster bootstrap configuration"
  exit 1
fi

echo "ArgoCD structure check passed"
exit 0
EOF

cat > tests/check_multicluster_config.sh << 'EOF'
#!/bin/bash
# Verifica configuração multi-cluster

# Verificar se existem configurações para múltiplos clusters
count=$(grep -r "cluster:" --include="*.yaml" . | wc -l)
if [ $count -ge 3 ]; then
  echo "Multiple cluster configurations found"
else
  echo "Not enough cluster configurations for multi-cluster setup"
  exit 1
fi

# Verificar ApplicationSets para deployments multi-cluster
if grep -q "ApplicationSet" applications/appsets/workloads-appset.yaml; then
  echo "ApplicationSet for multi-cluster deployment found"
else
  echo "Missing ApplicationSet configuration for multi-cluster deployment"
  exit 1
fi

echo "Multi-cluster configuration check passed"
exit 0
EOF

chmod +x tests/*.sh

# Instruções de implementação
cat > IMPLEMENTATION.md << 'EOF'
# Instruções de Implementação ArgoCD Multi-Cluster

## Pré-requisitos
- Múltiplos clusters EKS em diferentes contas AWS
- Permissões IAM para o ArgoCD acessar os clusters 
- Repositório Git configurado

## Passos de Implementação

### 1. Configurar o ArgoCD no cluster principal
```bash
# Aplicar a configuração base
kubectl apply -k argocd-config/overlays/cluster-tools

# Verificar se o ArgoCD está rodando
kubectl get pods -n argocd
EOF
