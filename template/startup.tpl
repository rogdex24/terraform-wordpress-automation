#! /bin/bash

# install docker
yum update -y
yum -y install docker git 
service docker start
chkconfig docker on
systemctl enable docker.service --now
usermod -a -G docker ec2-user

# install docker-compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose 
chmod +x /usr/bin/docker-compose


# setup nginx-proxy server
cd ~ && git clone --recurse-submodules https://github.com/evertramos/nginx-proxy-automation.git proxy 

find ./proxy/basescript/docker-compose -type f -exec sed -i 's/docker compose/docker-compose/g' {} +

cd proxy/bin

./fresh-start.sh --yes -e ${email}

cd ~

# start wordpress and phpmyadmin
cat << EOF > docker-compose.yml
${dockercompose}
EOF

docker-compose up -d
