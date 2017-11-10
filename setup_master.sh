#/bin/sh

apt-get update ; apt-get -y install curl git lsof lvm2 glusterfs-server; apt-get clean ; 
curl -sSL https://get.docker.com | sh ; 

curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /docker/nginx-proxy/ssl
mkdir -p /docker/nginx-proxy/vhost.d
mkdir -p /docker/nginx-proxy/html
mkdir -p /docker/rancher-server/mysql
mkdir -p /docker/share

mkdir -p /glusterfs
pvcreate -ff -y  /dev/sdb
vgcreate glustervg /dev/sdb
lvcreate -y glustervg  -n glusterlv1 -l 6399
mkfs.ext4 /dev/glustervg/glusterlv1
echo "/dev/glustervg/glusterlv1 /glusterfs ext4 defaults 0 0" >> /etc/fstab
mount /glusterfs

mkdir -p /docker/git_clone
cd /docker/git_clone
git clone https://github.com/cretinon/rancher-init.git

cd /docker/git_clone/nginx
docker-compose pull
docker-compose up -d

cd /docker/git_clone/rancher
docker-compose pull
docker-compose up -d
