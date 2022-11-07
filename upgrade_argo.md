To upgrade argo to latest version:

> sudo microk8s kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.3/quick-start-postgres.yaml

Then check if working or not, if not, restart fastapi server.
