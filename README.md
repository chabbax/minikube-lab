## Minikube Lab

#### Start Minikube

Creates 1 control-plane and 1 worker node (minikube and minikube-m02)

```
minikube start --nodes 2
```

#### Stop Minikube

Preserves cluster state and data (can be resumed later)

```
minikube stop
```

#### Delete Minikube

Destroys all Minikube VMs/containers and cluster data

```
minikube delete
```

# 1. On an Internet-connected workstation, add and update the necessary Helm repos:

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 2. Pull and unpack the Argo CD chart into your local charts directory:

helm pull argo/argo-cd \
 --version 8.0.14 \
 --untar \
 --destination terraform/helm/charts

# 3. Commit the unpacked chart folders into Git:

git add terraform/helm/charts/argocd
git add terraform/helm/charts/opencost
git commit -m "chore: add local Helm charts (ArgoCD v5.31.0, OpenCost v0.6.0)"
git push origin main
