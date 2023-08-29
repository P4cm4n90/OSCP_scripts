#!/bin/bash
## nmap automator https://github.com/21y4d/nmapAutomator
## nmap static binaries https://github.com/opsec-infosec/nmap-static-binaries
## DIR STRUCTURE IS AS FOLLOWS
## usage ./script.sh ip_list
## ip_list is list of ip adressses you want to scan
## build dir structure in /dev/shm/test
## /dev/shm/test/nmapAutomator
## /dev/shm/test/nmap - static binary
## /dev/shm/test/network - for results
## /dev/shm/network/script.sh - script location
## before running setup netcat listener on 4222
## I use ip_list instead of discovering ip by myself since i found out that nmap may not find all the hosts

while getopts n:l:s: flag
do
    case "${flag}" in
        n) nmap_dir=${OPTARG};;
        l) ip_list=${OPTARG};;
        s) scan_dir=${OPTARG};;
    esac
done

if [ -z "$nmap_dir" ] | [ -z "$ip_list" ] | [ -z "$scan_dir" ]; then
	echo "No arugments supplied. Supply arguments:"
	echo "-n <nmap and nmapAutomator executable dir>"
	echo "-l <file containing ip to scan>"
	echo "-s <directory to save scan results>"
	exit 
fi

while read i ; do
	if [ -d "$i" ]; then
		if [ -d "$i/scans" ]; then
			true
		else
			mkdir "$i/scans"
		fi
	else
		mkdir "$i";
		mkdir "$i/scans"
	fi
	## -s is location of nmap static binary
	"$nmap_dir/nmapAutomator" -H "$i" -t Full -o "$scan_dir/$i/scans" -s "$nmap_dir/nmap"
	wait
	"$nmap_dir/nmapAutomator" -H "$i" -t UDP -o "$scan_dir/$i/scans" -s "$nmap_dir/nmap"
	wait
done < $ip_list
