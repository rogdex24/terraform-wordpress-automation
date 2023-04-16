#!/bin/bash
sudo yum update -y
# install docker        
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# install phpmyadmin
sudo docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7
sudo docker run --name some-phpmyadmin --link some-mysql:db -d phpmyadmin/phpmyadmin
