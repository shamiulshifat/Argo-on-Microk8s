1. install docker from here:
> https://docs.docker.com/engine/install/ubuntu/
**********************************************
Now we setup offline docker repo locally:

https://stackoverflow.com/questions/35575674/how-to-save-all-docker-images-and-copy-to-another-machine

# to generate an offline docker image:

# docker save -o <generated tar file name> <repository_name:tag_name>
> docker save -o dockerofflinetrain.tar docker.io/library/dockerofflineimage:v1
for linux:
> sudo docker save -o dockerofflinetrain.tar docker.io/library/dockerofflineimage:v1

# to use that image in another machine:
 copy using pendrive or cloud, then open terminal on  current directory:

#
docker load -i <path to image tar file>

> docker load -i dockerofflinetrain.tar
 for linux:
> sudo load -i dockerofflinetrain.tar


###############################################
tasks to do for betterdata engine:

1. create a custom python image that has all the necessary libraries preinstalled. see mysql existahndler example
2. then build train dockerimage but dockerfile will have no pip install cmd bcz our python image alreday has it.
3. also need to create a private repository using below methods

#important:

use imagePullPolicy: never to get image from local
image: dockerofflineimage:v1
imagePullPolicy: Never
##################################################################
 This works for betterdata:::
setup:::
######################################################################
This should work irrespective of whether you are using minikube or not :

Start a local registry container:
> sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
 
Do docker images to find out the REPOSITORY and TAG of your local image. Then create a new tag for your local image :
 
> sudo docker tag <local-image-repository>:<local-image-tag> localhost:5000/<local-image-name>
 
If TAG for your local image is <none>, you can simply do:
 
here>  local repo: localhost:5000

docker tag <local-image-name> localhost:5000/<local-image-name>
 
> sudo docker tag train_model localhost:5000/train_model
 
Push to local registry :
 
> sudo docker push localhost:5000/<local-image-name>
 
> sudo docker push localhost:5000/train_model
 
This will automatically add the latest tag to localhost:5000/<local-image-name>. You can check again by doing docker images.

In your yaml file, set imagePullPolicy to IfNotPresent :
...
spec:
  containers:
  - name: <name>
    image: localhost:5000/<local-image-name>
    imagePullPolicy: IfNotPresent
...
That's it. Now your ImagePullError should be resolved.
 
 -------------------------------------------------
 for example:
 
 ```
 
sudo docker image build -t model_train_v5 .
sudo docker tag model_train_v5 localhost:5000/model_train_v5
sudo docker push localhost:5000/model_train_v5
 
 ```
 
 -----------------------------------------------

Note: If you have multiple hosts in the cluster, and you want to use a specific one to host the registry, just replace localhost in all the above steps with the hostname of the host where the registry container is hosted. In that case, you may need to allow HTTP (non-HTTPS) connections to the registry:

5 (optional). Allow connection to insecure registry in worker nodes:

sudo echo '{"insecure-registries":["<registry-hostname>:5000"]}' > /etc/docker/daemon.json


ref: 
1. https://stackoverflow.com/questions/36874880/kubernetes-cannot-pull-local-image
2 . https://linuxhint.com/setup_own_docker_image_repository/
