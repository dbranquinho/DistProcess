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
	
echo Generate key RSA for $username
ssh-keygen -t rsa -b 2048
for nodes in `cat config/nodes.dat|sort |uniq`
	do
	ssh-copy-id $username@$nodes
	done
echo "Remote machines created"
