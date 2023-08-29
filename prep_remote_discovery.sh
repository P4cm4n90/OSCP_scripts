#!/bin/bash
echo "Preparing Tools"
mkdir /tmp/test_disco
cp /usr/local/bin/nmapAutomator /tmp/test_disco
cp /home/p4cm4n/Pentest_Learning/linux_remote_tools/nmap_static.tar.gz /tmp/test_disco
cp /home/p4cm4n/Pentest_Learning/Offensive_Security/scripts/mass_scan.sh /tmp/test_disco
cp /home/p4cm4n/Pentest_Learning/Offensive_Security/it_network/ip_to_pwn /tmp/test_disco
zip tools.zip /tmp/test_disco/*
echo "Uploading Tools"
sshpass -p 'monkey' scp tools.zip sean@10.11.1.251:/home/sean/tools.zip
sshpass -p 'monkey' ssh sean@10.11.1.251 "mkdir /home/sean/test;mv /home/sean/tools.zip /home/sean/test/tools.zip;cd test;unzip -j /home/sean/test/tools.zip -d /home/sean/test/;tar -xvf nmap_static.tar.gz --directory /home/sean/test/;chmod +x /home/sean/test/*"
echo "Running automatic remote discovery"
sshpass -p 'monkey' ssh sean@10.11.1.251 "mkdir /home/sean/test/it_network;mv /home/sean/test/ip_to_pwn /home/sean/test/it_network/ip_to_pwn;mv /home/sean/test/mass_scan.sh /home/sean/test/it_network/mass_scan.sh; /home/sean/test/it_network/mass_scan.sh /home/sean/test/it_network/ip_to_pwn"
rm -R /tmp/test_disco