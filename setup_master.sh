#/bin/sh

dd if=/dev/zero of=/swap bs=1024 count=1024000
mkswap -c /swap 1024000
chmod 0600 /swap
swapon /swap

dd if=/dev/zero of=/dev/sdb bs=1024 count=10

apt-get update ; apt-get -y install curl git lsof lvm2 glusterfs-server; apt-get clean ; 

curl -sSL https://get.docker.com | sh ; 

curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

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
gluster volume create docker replica 2 transport tcp vps3.cretinon.fr:/glusterfs/docker vps4.cretinon.fr:/glusterfs/docker force
while [ $? -eq 1 ]; do sleep 10 ; gluster volume create docker replica 2 transport tcp vps3.cretinon.fr:/glusterfs/docker vps4.cretinon.fr:/glusterfs/docker force ; done
gluster volume start docker
echo "localhost:/docker /docker glusterfs defaults,_netdev 0 0" >> /etc/fstab
mount /docker
while [ $? -eq 1 ]; do sleep 10 ; mount /docker ; done

mkdir -p /docker/git_clone
cd /docker/git_clone
git clone https://github.com/cretinon/rancher-init.git
git clone https://github.com/rancher/compose-templates.git

mkdir -p /docker/bin
cd /docker/bin
wget https://github.com/rancher/rancher-compose/releases/download/v0.12.5/rancher-compose-linux-amd64-v0.12.5.tar.gz
tar zxvf rancher-compose-linux-amd64-v0.12.5.tar.gz
mv rancher-compose-v0.12.5/rancher-compose .
rm -rf rancher-compose-linux-amd64-v0.12.5.tar.gz
rm -rf rancher-compose-v0.12.5

cd /docker/git_clone/rancher-init/nginx
chmod +x start_nginx.sh
./start_nginx.sh

cd /docker/git_clone/rancher-init/rancher
chmod +x start_rancher.sh
./start_rancher.sh
