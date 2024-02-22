
#!/bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo -i
echo 'wirfon second server' > /var/www/html/index.html

