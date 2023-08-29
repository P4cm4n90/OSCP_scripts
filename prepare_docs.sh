#!/bin/bash
mkdir "/home/p4cm4n/Dropbox/Obsidian/CTF Walkthrough/Offensive Security/OSCP C"
docsFiles=("Enumeration.md"
	"Exploitation.md"
	"Post Exploitation.md"
	"Host Info")

internal=0

while read i; do                                 
	ip=$(echo $i | awk -F "." '{print $1"."$2".X."$4}')                                                              
	dir_name="$(pwd)/$ip"
	mkdir "$dir_name";mkdir "$dir_name/scans" 2>/dev/null
	mkdir "/home/p4cm4n/Dropbox/Obsidian/CTF Walkthrough/Offensive Security/OSCP C/$ip" 2>/dev/null
	for k in $(echo ${!docsFiles[@]}); do
		touch "/home/p4cm4n/Dropbox/Obsidian/CTF Walkthrough/Offensive Security/OSCP C/$ip/${docsFiles[k]}" 2>/dev/null
	done
	if [[ $(echo "$i" | grep "192.168") ]]; then
		nmapAutomator -H $i -t Full -o "$dir_name/scans" &
	else
		internal=1
		proxychains -q nmap -top 200 -T5 -Pn $i -o "$dir_name/scans/nmap_top_200" &
	fi
done < "$1"

if [ $internal == 1 ]; then
	wait
	while read i; do
		ip=$(echo $i | awk -F "." '{print $1"."$2".X."$4}')                                                              
		dir_name="$(pwd)/$ip"
		ports=$(cat "$dir_name/scans/nmap_top_200" | awk -F "/" '{print $1}' | grep "^[0-9]" | tr '\n' ','  | rev | cut -c 2- | rev)
		nmap -sCV -p"$ports" $i -o "$dir_name/scans/nmap_complete_200"
	done < "$1"
fi