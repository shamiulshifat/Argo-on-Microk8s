#!/bin/bash
echo "Installing CIS hardened Kubernetes"
sudo snap install microk8s --classic --channel=1.28/stable
sudo usermod -a -G microk8s
sudo chown -f -R $USER ~/.kube
echo "Checking Kubernetes Installaion"
microk8s status --wait-ready
SUBNET=`cat /var/snap/microk8s/current/args/cni-network/cni.yaml | grep CALICO_IPV4POOL_CIDR -a1 | tail -n1 | grep -oP '[\d\./]+'`
echo $SUBNET
sudo firewall-cmd --permanent --new-zone=microk8s-cluster
sudo firewall-cmd --permanent --zone=microk8s-cluster --set-target=ACCEPT
sudo firewall-cmd --permanent --zone=microk8s-cluster --add-source=$SUBNET
sudo firewall-cmd --reload
microk8s enable dashboard
microk8s enable gpu
echo "installed microk8s successfully!"
echo "------------------"
echo "installing docker"
microk8s enable dns
# check if docker installed properly
docker run hello-world
echo "------------------"
echo "installing argo"
#now we have to install a local docker repo:
#sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
cd ../
cd ./docker_registry/
sudo bash registry_setup.sh
cd ../
cd ./ml_setup/
echo "wait 1 minutes to get docker registry container running"
sleep 1m
### argo installation starts ##########
microk8s kubectl create ns argo
## install latest argo
microk8s kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.8/quick-start-postgres.yaml
# wait 2 minutes and check on kubernetes dashboard on "argo" namespace whether all pods are running or not!
echo "wait 2 minutes to get argo server full running"
sleep 2m
#you can check
microk8s kubectl get pods -n argo
## now deploy some argo configs
microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/Argo-on-Microk8s/main/service-account.yaml -n argo
microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/Argo-on-Microk8s/main/workflow-servoce-account.yaml -n argo
microk8s kubectl create ns argo-events
# Install Argo Events
microk8s kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
# Deploy the Event Bus
microk8s kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
#again deploy for argo namespace
microk8s kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
# deploy priority class
microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/argo-practice/main/setpriority.yaml -n argo
echo "installed argo successfully!"
echo "wait 2 minutes to get argo events full running"
sleep 2m
echo "deployed argo server successfully"
#inject git secrets
cd ../
cd ./k8s_secrets/
bash credential_loader_rhel.sh
cd ../
cd ../
docker login localhost:5000
cd ./Core_ML_Deployment/ML_engine_image/
echo "deploying core ML Engine image"
docker image build -t ml_engine_v2:latest .
docker tag ml_engine_v2:latest localhost:5000/ml_engine_v2:latest
docker push localhost:5000/ml_engine_v2:latest
cd ../
echo "installing training sensor"
microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/argo-practice/main/setpriority.yaml
microk8s kubectl apply -f ./train_manifests/train_sensor_gpu.yaml -n argo --validate=false
microk8s kubectl apply -f ./train_manifests/train_eventsource.yaml -n argo --validate=false
echo "installing training-priority sensor"
microk8s kubectl apply -f ./train_manifests/train_sensor_priority_gpu.yaml -n argo --validate=false
microk8s kubectl apply -f ./train_manifests/train_eventsource_priority.yaml -n argo --validate=false

echo "deploying sidecar for inference image"
cd ./sidecar/image/
docker image build -t sidecar_v1:latest .
docker tag sidecar_v1:latest localhost:5000/sidecar_v1:latest
docker push localhost:5000/sidecar_v1:latest
cd ../
cd ../

microk8s kubectl apply -f ./generate_manifests/gen_sensor_gpu.yaml -n argo --validate=false
microk8s kubectl apply -f ./generate_manifests/gen_eventsource.yaml -n argo --validate=false
echo "deploying exit-handler image"
cd ./exithandler/image/
docker image build -t exithandler_v1:latest .
docker tag exithandler_v1:latest localhost:5000/exithandler_v1:latest
docker push localhost:5000/exithandler_v1:latest
cd ../
cd ../
echo "deploying metrics image"
cd ./metrics/image/
docker image build -t metrics_engine_v2:latest .
docker tag metrics_engine_v2:latest localhost:5000/metrics_engine_v2:latest
docker push localhost:5000/metrics_engine_v2:latest
cd ../
cd ../
microk8s kubectl apply -f ./metrics_manifests/metrics_sensor.yaml -n argo --validate=false
microk8s kubectl apply -f ./metrics_manifests/metrics_eventsource.yaml -n argo --validate=false
echo "workflows deployed successfully!"
echo "check -> training, gen, metrics sensors pods running or not!"
microk8s kubectl get pods -n argo
echo "let's install fastapi"
cd ../
cd ./installation_scripts/
cd ./fastapi_server/ml_fastapi_server/image/
docker build -t mlfastapi_server:v1 .
docker tag mlfastapi_server:v1 localhost:5000/mlfastapi_server:v1
docker push localhost:5000/mlfastapi_server:v1
cd ../
microk8s kubectl apply -f ./MLFastapi_deployment.yaml --validate=false
echo "fastapi server for ML is deployed successfully!"
echo "ML deployment is completed!!"
echo "------------------------------------------------------"
echo "Thanks for choosing **BETTERDATA** Synthetic Data Engine!!"
echo "Limiting file and event watcher"
cat /proc/sys/fs/inotify/max_user_instances 
sudo sysctl fs.inotify.max_user_instances=2099999999
cat /proc/sys/fs/inotify/max_user_instances
sudo sysctl -w fs.inotify.max_user_watches=2099999999
sudo sysctl -w fs.inotify.max_user_instances=2099999999
sudo sysctl -w fs.inotify.max_queued_events=2099999999
#to kill 8000 port
#sudo lsof -t -i:8000
#ps aux | grep 'fast_api_deployment:app' | grep -v grep
#sudo kill -9 pid
# or
#fuser -n tcp -k 8000
