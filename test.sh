while [ `ls config/node*.ctl |wc -l` -gt 0 ] ;
	do
	echo wait
	sleep 3
	done
