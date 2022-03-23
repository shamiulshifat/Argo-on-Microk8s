## learn argo from here: 
https://100daysofkubernetes.io/tools/argo.html?highlight=argo#argo-workflows

for installlation- argo workflows-events. follow this:

first install microk8s dns or it will not let u install workflow controller, server:
```
microk8s enable dns
```
then install if want minio pre configured:
```
kubectl create namespace argo-events
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
```
then for event based workflow:

https://sdbrett.com/post/2021-06-18-integrate-argo-wf-events/



*****************************
kubectl --kubeconfig ./admin.conf
export KUBECONFIG=/path/to/admin.conf

***********************
for proxy kill:

https://dev4devs.com/2020/05/25/how-to-kill-the-kubectl-proxy/

**************************
