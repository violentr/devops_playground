#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2> Webserver with ip: $myip</h2></br> Build by terraform!" > /var/www/html/index.html
echo "<h2> Hello World" >> /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
