#/bin/sh

apt-get update ; apt-get -y install curl git lsof lvm2 glusterfs-server nfs-common; apt-get clean ; 
curl -sSL https://get.docker.com | sh ; 

mkdir -p /glusterfs
pvcreate -ff -y  /dev/sdb
vgcreate glustervg /dev/sdb
lvcreate -y glustervg  -n glusterlv1 -l 6399
mkfs.ext4 /dev/glustervg/glusterlv1
echo "/dev/glustervg/glusterlv1 /glusterfs ext4 defaults 0 0" >> /etc/fstab
mount /glusterfs

mkdir /docker
gluster peer probe vps3.cretinon.fr
echo "localhost:/docker /docker glusterfs defaults,_netdev 0 0" >> /etc/fstab
mount /docker
