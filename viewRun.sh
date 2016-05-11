#!/bin/bash

clear
if [ -d run ] ; then
	echo "Node running available to see:"
	ls run
	echo " "
else
	echo "ERROR: there is no run directory"
	read a
	exit
fi
echo -e "Node number? \c"
read node
if [ ! -d run/node$node ] ; then
	echo "Node does not exist"
	read a
	exit
fi

flag=" "
while [ "$flag" != "x" ] ;
	do
	clear
	echo -e "Log from running node$node\n\n"
	cat run/node$node/run.log
	echo -e "\n<<< ENTER to refresh - x to finish - number node to see others>>>"
	read flag
	if [ $flag != ' ' ] || [ $flag != '\n' ] ; then
		node=$flag
	fi
	done
