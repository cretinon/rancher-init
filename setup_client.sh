#/bin/sh

dd if=/dev/zero of=/swap bs=1024 count=1024000
mkswap -c /swap 1024000
chmod 0600 /swap
swapon /swap

apt-get update ; apt-get -y install curl git lsof lvm2 glusterfs-server nfs-common; apt-get clean ; 
curl -sSL https://get.docker.com | sh ; 

mkdir -p /glusterfs
pvcreate -ff -y  /dev/sdb
vgcreate datavg /dev/sdb
lvcreate -y datavg  -n glusterlv1 -l 500
mkfs.ext4 /dev/datavg/glusterlv1
echo "/dev/datavg/glusterlv1 /glusterfs ext4 defaults 0 0" >> /etc/fstab
mount /glusterfs
mkdir -p /docker_local
lvcreate -y datavg  -n locallv1 -l 500
mkfs.ext4 /dev/datavg/locallv1
echo "/dev/datavg/locallv1 /docker_local ext4 defaults 0 0" >> /etc/fstab
mount /docker_local

mkdir /docker
gluster peer probe vps3.cretinon.fr
echo "localhost:/docker /docker glusterfs defaults,_netdev 0 0" >> /etc/fstab
mount /docker
while [ $? -eq 1 ]; do sleep 10 ; mount /docker ; done
