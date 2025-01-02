to remove cuda completely:
```
sudo apt-get --purge remove "*cublas*" "cuda*" "nsight*" 
sudo apt-get --purge remove "*cublas*" "*cufft*" "*curand*" \
 "*cusolver*" "*cusparse*" "*npp*" "*nvjpeg*" "cuda*" "nsight*" 

sudo apt-get --purge remove "*nvidia*"

sudo rm -rf /usr/local/cuda*

sudo apt-get purge nvidia*
sudo apt-get autoremove
sudo apt-get autoclean
sudo rm -rf /usr/local/cuda*

```
then reboot vm: very important!!

```
sudo reboot

```

Now we install cuda:

```
lspci | grep -i NVIDIA

sudo apt update && sudo apt install -y ubuntu-drivers-common

sudo ubuntu-drivers install

sudo reboot

sudo apt update

sudo apt install -y nvidia-container-toolkit
```
if has secure boot enabled, follow this: https://learn.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup
then reboot vm: very important!!

```
sudo reboot

```

then verify if cuda is working or not:

```
nvidia-smi
```


#############################
cuda installation:

official doc:

https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

but can follow this link for easy:

https://linuxize.com/post/how-to-nvidia-drivers-on-ubuntu-20-04/

then follow these steps:

https://discuss.kubernetes.io/t/my-adventures-with-microk8s-to-enable-gpu-and-use-mig-on-a-dgx-a100/15366

#########################
to see if gpu is attached with k8s:
```
microk8s kubectl get nodes -o yaml | grep gpu
```


------------------------optimal code:

Update the system and install prerequisites:

```
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential dkms
```
Add the NVIDIA package repository:
```
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
```
Install the NVIDIA driver:

You need to install the appropriate NVIDIA driver for your GPU. For NVIDIA L20, a suitable driver version is usually 450 or later. You can install it with:

With the latest driver version compatible with your GPU if needed.

Reboot your system:
```
sudo apt install -y nvidia-driver-460


sudo reboot
```


Verify the NVIDIA driver installation:

After rebooting, check if the NVIDIA driver is correctly installed:

```
nvidia-smi
```
--------------
if still does not work, try this:

sudo ubuntu-drivers autoinstall

Install CUDA toolkit:

You need the CUDA toolkit to utilize the GPU for Kubernetes workloads. Follow the official CUDA installation guide for Ubuntu here.

For example, to install CUDA 11.2, you can use the following commands:

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt update
sudo apt install -y cuda
```
Install NVIDIA container toolkit:

This toolkit is required to run GPU workloads in containers.

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker
```
------------------------------------
