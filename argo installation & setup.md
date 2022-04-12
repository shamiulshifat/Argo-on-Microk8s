## learn argo from here: 
https://100daysofkubernetes.io/tools/argo.html?highlight=argo#argo-workflows

for installlation- argo workflows-events. follow this:

first install microk8s dns or it will not let u install workflow controller, server:
```
microk8s enable dns
```
then install docker:

https://docs.docker.com/engine/install/ubuntu/


then install if want minio pre configured:
```
kubectl create ns argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/quick-start-postgres.yaml

```
###########################
run 
```
kubectl -n argo port-forward deployment/argo-server 2746:2746
```

go to: 
https://localhost:2746/workflows?limit=500


#######################
then for event based workflow:

https://sdbrett.com/post/2021-06-18-integrate-argo-wf-events/

important event note:

-deploy everything under "argo" namespace.

use this service account yaml and workflow service account from here:

https://github.com/shamiulshifat/Argo-on-Microk8s/tree/main

***********************
```
kubectl create ns argo-events
# Install Argo Events
 kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
# Deploy the Event Bus

 kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
#again deploy for argo namespacee
 kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
```
now deploy every sensor, event source under "argo" namespace

use this service account yaml and workflow service account from here:

https://github.com/shamiulshifat/Argo-on-Microk8s/tree/main


then run webhook for a http webhook:
```
kubectl -n argo port-forward $(kubectl -n argo get pod -l eventsource-name=webhook-titanic -o name) 8080:8080
```

*****************************
kubectl --kubeconfig ./admin.conf
export KUBECONFIG=/path/to/admin.conf

***********************
for proxy kill:

https://dev4devs.com/2020/05/25/how-to-kill-the-kubectl-proxy/

**************************
