### Install Tools
```s
az aks install-cli or winget install --id=Kubernetes.kubectl  -e
winget install --id=Microsoft.Azure.Kubelogin  -e
az extension add --name aks-preview
az extension add --name alb
winget install Helm.Helm
```
### Login 
```s
az login
kubelogin convert-kubeconfig -l azurecli
az aks get-credentials --resource-group rg-aks-dev-01 --name aks-dev-01 --overwrite-existing
```
### Nodes
```s
kubectl get node -o wide
kubectl get node virtual-node-aci-linux -o yaml
kubectl describe node virtual-node-aci-linux
kubectl debug node/aks-default-31145797-vmss000000 -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
```
### Pods
```s
kubectl get pod -A -o wide
kubectl get pod -n kube-system 
kubectl get pod -n kube-system ingress-appgw-deployment-5c76c67cbb-w9zml -o yaml
kubectl describe pod -n kube-system ingress-appgw-deployment-5c76c67cbb-w9zml
```
### Deploy
```s
kubectl create deploy my-simple-website --image andreibarbu95/my-simple-website:v1
kubectl expose deploy my-simple-website --name my-simple-website-lb --type LoadBalancer --port 80
kubectl get deployment
kubectl describe deployment my-simple-website
kubectl delete deploy my-simple-website
```
### Deploy with Application gateway ingress controller
##### After infra deployment, go to node rg > Deployment > Redeploy failed deployment
##### You may need to remove existing ingress-appgw pod before app deployment
```s
kubectl create deploy my-simple-website-agw --image andreibarbu95/my-simple-website:v1
kubectl expose deploy my-simple-website-agw --name myingress-srv --port 80
kubectl apply -f ./deployments/agic-app.yaml
kubectl get pod,svc,ing
```
### Get Stateful sets
```s
kubectl get statefulsets
kubectl delete statefulsets statefulset-blob-nfs
```
### Deploy virtual node (Azure Container Instance)
```s
kubectl apply -f ./deployments/nginx-test-virtual-node.yaml
kubectl get pod nginx-test-virtual-node-85b6c7d6fb-2bsff
kubectl describe pods nginx-test-virtual-node-85b6c7d6fb-2bsff
kubectl delete pod nginx-test-virtual-node-85b6c7d6fb-2bsff
kubectl scale deploy nginx-test-virtual-node --replicas 1
```
### Create Azure Disk
#### https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#dynamically-create-azure-disks-pvs-by-using-the-built-in-storage-classes
```s
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/pvc-azuredisk-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml
kubectl get sc managed-csi -o yaml
kubectl get pvc pvc-azuredisk -o yaml
kubectl exec -it nginx-azuredisk -- df -h /mnt/azuredisk
kubectl exec -it nginx-azuredisk -- sh #run linux command
kubectl patch pvc pvc-azuredisk --type merge --patch '{"spec": {"resources":{"requests": {"storage": "15Gi"}}}}'
```

### Create storage account file with privat endpoint
#### https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#create-a-custom-storage-class
#### https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#dynamically-provision-a-volume
```s
kubectl get sc azurefile-csi -o yaml
kubectl apply -f ./deployments/sc-private-storage.yaml
kubectl get sc azurefile-csi-pep
kubectl delete sc azurefile-csi-pep
kubectl apply -f ./deployments/pvc-private-storage.yaml
kubectl describe pvc azurefile-csi-pep
kubectl delete pvc azurefile-csi-pep
```
### Create storage account blob(nfs & fuse) using a StatefulSet
#### https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi?tabs=NFS#using-a-statefulset
```s
kubectl apply -f ./deployments/blob-nfs.yaml
kubectl apply -f ./deployments/blob-blobfuse.yaml
kubectl get pod
kubectl describe pod statefulset-blob-nfs-0
kubectl exec -it statefulset-blob-nfs-0 -- sh
kubectl get pv,pvc
kubectl delete pvc persistent-storage-statefulset-blob-nfs-0 --force
kubectl describe pvc persistent-storage-statefulset-blob-nfs-0 
```
### Remove storage account blob(nfs & fuse) using a StatefulSet
```s
kubectl get statefulsets
kubectl delete statefulsets statefulset-blob-nfs
```
### Deploy ACR App
```s
kubectl apply -f ./deployments/my-acr-app.yaml
kubectl get pod my-simple-website-78694574f4-bbndv -o yaml
kubectl get pod my-devops-website-5ff698ff6d-7ltjj -o yaml
kubectl describe pod myapp
kubectl delete pod myapp
```
### Yaml Deployment
```s
kubectl create deploy my-app --image acrboombasticdev01.azurecr.io/sample/hello-world:v1 --dry-run=client -o yaml > ./kubernetes01/manifests/my-app.yaml
kubectl expose deploy my-app --type LoadBalancer --port 80 --dry-run -o yaml > ./kubernetes01/manifests/my-app-svc-lb.yaml
kubectl apply -f ./kubernetes01/manifests/my-app.yaml
kubectl apply -f ./kubernetes01/manifests/my-app-svc-lb.yaml
```
### Application Gateway for Containers
#### https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller?tabs=install-helm-windows
```s
kubectl create ns azure-alb-system

$HELM_NAMESPACE='azure-alb-system'
$CONTROLLER_NAMESPACE='azure-alb-system'
$RESOURCE_GROUP = 'rg-aks-dev-01'

helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller `
     --namespace $HELM_NAMESPACE `
     --version 1.4.12 `
     --set albController.namespace=$CONTROLLER_NAMESPACE `
     --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n azure-alb-identity --query clientId -o tsv)

kubectl get crd
```
### Application Gateway for Containers Routed Traffic
```s
kubectl create ns alb-test-infra
kubectl apply -f ./deployments-alb/alb.yaml
kubectl get applicationloadbalancer alb-test -n alb-test-infra -o yaml

kubectl apply -f ./deployments-alb/resources.yaml
kubectl get pod,svc -n test-infra
kubectl get gatewayclass
kubectl apply -f ./deployments-alb/gateway.yaml
kubectl get gateway gateway-01 -n test-infra -o yaml
nslookup dmasavawhad3ejfg.fz80.alb.azure.com

kubectl apply -f ./deployments-alb/httproute.yaml
kubectl get httproute traffic-split-route -n test-infra -o yaml
kubectl get gateway gateway-01 -n test-infra 

kubectl create deploy nginx --image nginx
kubectl expose deploy nginx --port 80 --name nginx-svc
kubectl get ingressclass
kubectl apply -f ./deployments-alb/ingress.yaml
kubectl get ingress ingress-01 -o yaml
nslookup cnewffg8d9g5hga4.fz34.alb.azure.com
kubectl get crd
kubectl get applicationloadbalancer -A
kubectl delete applicationloadbalancer alb-test -n alb-test-infra
```
