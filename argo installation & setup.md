## learn argo from here: 
https://100daysofkubernetes.io/tools/argo.html?highlight=argo#argo-workflows

just use this yaml for deployment: 

https://github.com/argoproj/argo-workflows

https://argoproj.github.io/argo-workflows/quick-start/

use this: 
```
kubectl create ns argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/quick-start-postgres.yaml
```

*****************************
kubectl --kubeconfig ./admin.conf
export KUBECONFIG=/path/to/admin.conf

***********************
