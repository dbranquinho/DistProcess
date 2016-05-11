#!/bin/bash

while :; 
	do 
	clear
	echo -e "*** Clusters=`grep cluster config/config.dat|cut -f2 -d'='` - Files=`cat config/files.dat|wc -l` - Terms=`cat config/term.dat|wc -l`\n"
	if [ `ls index|grep cluster|wc -c` -gt 0 ] ; then
		ls index/cluster*
	else
		echo "Clusters not found!"
	fi
	echo -e "\n\n<<< Enter = refresh           x = Exit >>>"
	read a
	if [ "$a" == "x" ] ; then
		exit
	fi
	done

