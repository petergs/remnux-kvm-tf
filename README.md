# remnux-kvm-tf
> Small terraform module and script to quickly bootstrap a REMnux VM running under KVM

REMnux releases virtual appliances in [OVA](https://docs.remnux.org/install-distro/get-virtual-appliance) 
format. The `setup.sh` script converts an `.ova` into `.qcow2` and moves it to a libvirt storage pool 
for use by the terraform module. 

The terraform module creates an isolated network called `malnet` and creates a REMnux VM with a 
network interface on that network. 

## Setup 
1. Run `setup.sh`. 
2. Set terraform variables as desired. Set the `pool_name` variable to the one used for `setup.sh`.
3. `terraform apply`

## Troubleshooting 
- Had a issue of a black screen on boot that I resolved by removing `quiet splash $vt_handoff` kernel 
parameters via the GRUB boot menu and then permanently once booted. See 
[this](https://askubuntu.com/questions/1240152/boot-freezes-and-loading-initial-ramdisk) askubuntu thread.
- My network interfaces weren't managed by NetworkManager. Here's one [solution](https://askubuntu.com/a/1075112) 
if you want to use NetworkManager.
