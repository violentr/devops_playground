#!/bin/bash
yum -y update
yum -y install httpd
cat <<EOF > /var/www/html/index.html
<html>
<h2> Webserver was provisioned by terraform</h2></br>
<p> Was deployed by ${f_name} </p>
%{ for name in friends ~}
<h2> Hello ${name} !</h2></br>
%{ endfor ~}
</html>
EOF
sudo service httpd start
chkconfig httpd on
