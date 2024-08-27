#!/bin/bash
echo "------------------------------------------------"
echo "installing microk8s"
sudo apt-get update -y
#non gpu microk8s. for gpu microk8s, use: channnel=1.22 #v1.25 has bugs
sudo snap install microk8s --classic --channel=1.28/stable
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
#check
microk8s status --wait-ready
sudo microk8s enable dashboard
echo "installed microk8s successfully!"
sudo microk8s enable dns
# install docker
sudo apt-get remove -y docker docker-engine docker.io containerd runc
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list  /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
# check if docker installed properly
sudo docker run hello-world
echo "installed docker successfully!"
### argo installation starts ##########
sudo microk8s kubectl create ns argo
## install latest argo
sudo microk8s kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.8/quick-start-postgres.yaml
# wait 2 minutes and check on kubernetes dashboard on "argo" namespace whether all pods are running or not!
echo "wait 2 minutes to get argo server full running"
sleep 2m
#you can check
sudo microk8s kubectl get pods -n argo
## now deploy some argo configs
sudo microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/Argo-on-Microk8s/main/service-account.yaml -n argo
sudo microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/Argo-on-Microk8s/main/workflow-servoce-account.yaml -n argo
sudo microk8s kubectl create ns argo-events
# Install Argo Events
sudo microk8s kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
# Deploy the Event Bus
sudo microk8s kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
#again deploy for argo namespace
sudo microk8s kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
# deploy priority class
sudo microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/argo-practice/main/setpriority.yaml -n argo
echo "installed argo successfully!"
echo "wait 2 minutes to get argo events full running"
sudo microk8s kubectl apply -f https://raw.githubusercontent.com/shamiulshifat/argo-practice/main/setpriority.yaml
sudo microk8s kubectl create ns frontend
sudo microk8s kubectl create ns backend
echo "------------------------------------------------------"
echo "Limiting file and event watcher"
cat /proc/sys/fs/inotify/max_user_instances 
sudo sysctl fs.inotify.max_user_instances=2099999999
cat /proc/sys/fs/inotify/max_user_instances
sudo sysctl -w fs.inotify.max_user_watches=2099999999
sudo sysctl -w fs.inotify.max_user_instances=2099999999
sudo sysctl -w fs.inotify.max_queued_events=2099999999
