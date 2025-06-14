# Argo CD Directory Layout

This directory contains all resources and configurations used by Argo CD to manage applications via an App-of-Apps pattern.

```
minikube-lab/
└── argocd/
    |
    ├── apps/                       # Argo CD Application manifests (App-of-Apps)
    │   ├── dashboard.yaml          # Child Application for Kubernetes Dashboard
    │   └── opencost.yaml           # Child Application for OpenCost
    |
    ├── charts/                     # Vendored or CI-pulled Helm charts
    │   ├── argo-cd/                # (Optional) Custom Argo CD Helm chart sources
    │   └── dashboard/              # Vendored Kubernetes Dashboard chart (air-gapped)
    |
    ├── values/                     # Environment-agnostic Helm value overrides
    │   ├── argocd-values.yaml      # Overrides for Argo CD Helm chart
    │   ├── dashboard-values.yaml   # Overrides for Kubernetes Dashboard chart
    │   └── opencost-values.yaml    # Overrides for OpenCost Helm chart
    |
    ├── README.md
    └── root.yaml                   # Root “apps” Application that bootstraps all child apps
```

## Folder Purpose

- **apps/**: Contains Argo CD `Application` CRDs. `root.yaml` bootstraps the folder, causing Argo CD to create and manage each child application (`dashboard.yaml`, `opencost.yaml`).
- **charts/**: Stores full Helm chart sources that are either vendored for air-gapped environments (e.g. `dashboard/`) or managed by CI pipelines. Public charts (like OpenCost) can be pulled on-the-fly.
- **values/**: Houses standalone, environment-agnostic `values.yaml` files to customize chart deployments (e.g. service types, RBAC, ingress settings).

## Pulling Helm Charts

### 1. Private pull (vendored charts)

When you need to run in an air-gapped cluster, vendor the chart into `charts/`:

```bash
# Add upstream repo (if not already added locally)
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# Go into the argocd directory
cd argocd

# Pull and untar the chart into charts/
helm pull kubernetes-dashboard/kubernetes-dashboard \
  --version 7.13.0 --untar --destination charts/

# (Optional) Rename folder to match structure
mv charts/kubernetes-dashboard charts/dashboard
```

This creates:

- `charts/dashboard/Chart.yaml`
- `charts/dashboard/templates/...`
- `charts/dashboard/values.yaml`

### 2. Public pull (runtime fetch)

For public charts you don’t need to vendor locally; Argo CD will pull from the Helm repo directly:

```bash
# Add the public Helm repo
helm repo add opencost https://opencost.github.io/opencost-helm-chart
helm repo update
```

In your Application CR (`opencost.yaml`), reference the repo and chart:

```yaml
source:
  repoURL: https://opencost.github.io/opencost-helm-chart
  chart: opencost
  targetRevision: 2.1.4
```

## Files to Create

| File Path                      | Purpose                                      |
| ------------------------------ | -------------------------------------------- |
| `argocd/apps/root.yaml`        | Root Application to bootstrap all child apps |
| `argocd/apps/dashboard.yaml`   | Child App for vendored Kubernetes Dashboard  |
| `argocd/apps/opencost.yaml`    | Child App for public OpenCost chart          |
| `values/dashboard-values.yaml` | Values override for Dashboard chart          |
| `values/opencost-values.yaml`  | Values override for OpenCost chart           |
| `values/argocd-values.yaml`    | Overrides for Argo CD Helm chart (if in use) |

### Example `values/dashboard-values.yaml`

```yaml
service:
  type: NodePort
  nodePort: 30001
rbac:
  enabled: true
metrics:
  enabled: true
ingress:
  enabled: false
```

### Example `values/opencost-values.yaml`

```yaml
service:
  type: ClusterIP
replicaCount: 1
prometheus:
  enabled: true
grafana:
  enabled: false
```

### (Optional) `values/argocd-values.yaml`

Use this if you install Argo CD itself via Helm and want to customize it:

```yaml
server:
  service:
    type: NodePort
    nodePortHttp: 30081
    nodePortHttps: 30444
global:
  nodeSelector:
    kubernetes.io/hostname: minikube-m02
```

With these commands and files in place, you can seamlessly manage both private and public Helm charts through Argo CD’s App-of-Apps pattern. Simply:

1. Ensure charts are vendored or repos added as above.
2. Commit `apps/`, `charts/` (for private), and `values/`.
3. Apply the root bootstrap:

   ```bash
   kubectl apply -n argocd -f argocd/apps/root.yaml
   ```

4. Verify all child Applications (`dashboard`, `opencost`) sync to **Synced/Healthy**.

## Bootstrap Argo CD with the root App

Argo CD will then auto-discover child Applications

```bash
kubectl apply -n argocd -f argocd/root.yaml
```
