
#!/bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo -i
echo 'wirfon first server' > /var/www/html/index.html

