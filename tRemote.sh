#!/bin/bash

if [ ! -f config/config.dat ] ; then
	echo "ERROR - Config file not found!"
	exit
fi

username=`grep username config/config.dat|cut -f2 -d '='`
if [ "$username" == "" ] ; then
	echo "Username not found"
	exit
fi

if [ ! -f config/nodes.dat ] ; then
	echo "Nodes IP file not found"
	exit
fi
	
for nodes in `cat config/nodes.dat|sort|uniq`
	do
	test=`ping -c 3 $nodes |grep 64|wc -l`
	if [ $test -gt 0 ] ; then
		echo -e "Node $nodes with `grep $nodes config/nodes.dat|wc -l` machines ok! - \c"
		ssh delermando@$nodes echo $nodes >nodes/$nodes
		flag=`ls nodes/$nodes|wc -l`
		if [ $flag -gt 0 ] ; then
			echo "NFS ok!"
		else
			echo "NFS ERROR!"
		fi
		rm nodes/$nodes
	else
		echo "Node $nodes ERROR"
	fi
	done
echo "Test finished"
