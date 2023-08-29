#!/bin/bash
## this script should be in directory where will be folders

while getopts p:l:s: flag
do
    case "${flag}" in
        l) ip_list=${OPTARG};;
        s) scan_dir=${OPTARG};;
		p) ports=${OPTARG};;
    esac
done

if [ -z $ports ]; then
	ports=-p-
else
	ports="-top $ports"
fi

if [ -z "$ip_list" ] | [ -z "$scan_dir" ]; then
	echo "No arugments supplied. Supply arguments:"
	echo "-l <file containing ip to scan>"
	echo "-s <directory to save scan results>"
	exit 
fi

ports_out=$(echo $ports | sed -e 's/-p-//g' -e 's/-top /top_/g')

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
	echo starting scan on $i
	nmap -T5 -Pn $ports "$i" -oN "$scan_dir/$i/scans/nmap_full$ports_out" &

done < $ip_list
wait
echo "First scan ended"
echo "Starting new scan"
while read i ; do
	ports=$(cat "$i/scans/nmap_full$ports_out" | awk -F "/" '{print $1}' | grep "^[0-9]" | tr '\n' ','  | rev | cut -c 2- | rev)
	nmap -sCV -p $ports $i -oN "$scan_dir/$i/scans/nmap_complete$ports_out" &
done < $ip_list
