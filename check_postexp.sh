#!/bin/bash
main_dir="/home/p4cm4n/Pentest_Learning/Offensive_Security/public_network"
directories=( $(ls $main_dir) )

temp_file=$(mktemp)

for d in "${directories[@]}"; do
	samhashfile="$main_dir/$d/post_exploitation/system_hashes.sam" 
	credsfile="$main_dir/$d/post_exploitation/system_credentials"
	if [ -f $samhashfile ]; then
		if [ "$1" = "users" ]; then
			cat $samhashfile | grep -Ev '\[|Impacket' |  awk -F ":" '{print $1}' | grep "\S" >> $temp_file
			cat $credsfile | grep "\S" >> $temp_file2
		fi
		if [ "$1" = "all" ]; then
			cat $samhashfile | grep -Ev '\[|Impacket' | grep "\S" >> $temp_file
		fi
	fi

	if [ "$1" = "creds" ]; then
		if [ -f $credsfile ]; then	
			cat $credsfile | grep "\S" >> $temp_file
		fi
	fi
done

if [ "$1" = "creds" ]; then
	cat $temp_file | sort
else
	cat $temp_file | sort | uniq
fi

rm ${temp_file}

