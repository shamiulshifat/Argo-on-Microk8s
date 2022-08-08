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
then reboot vm:

```
sudo reboot

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
