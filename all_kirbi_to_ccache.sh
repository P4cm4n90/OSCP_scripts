#!/bin/bash

for f in $(ls); do
	if [[ $f == *.kirbi ]]; then
		name=$(echo $f| awk -F ".kirbi" '{print $1}')
		impacket-ticketConverter "$f" "$name.ccache"
	fi
done
