#!/bin/bash
## this script should be in directory where will be folders

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

	if [ -f "$scan_dir/$i/scans/nmap_full" ]; then
		continue
	fi

	"$nmap_dir/nmap" -T4 -Pn -p- "$i" -oN "$scan_dir/$i/scans/nmap_full" &

	if [ -f "$scan_dir/$i/scans/nmap_udp" ]; then
		continue
	fi

	"$nmap_dir/nmap" -T4 -sU "$i" -oN "$scan_dir/$i/scans/nmap_udp" &

done < $ip_list
wait
echo "First scan ended"
echo "Starting new scan"
while read i ; do
	ports=$(cat "$i/scans/nmap_full" | awk -F "/" '{print $1}' | grep "^[0-9]" | tr '\n' ','  | rev | cut -c 2- | rev)
	"$nmap_dir/nmap" -sCV -p $ports $i -oN "$scan_dir/$i/scans/nmap_complete" &
done < $ip_list