#!/bin/bash

echo Copying ...
cont=0
collection=`grep collection config/config.dat|cut -f2 -d'='`
classpath=`grep classpath config/config.dat|cut -f2 -d'='`
sample=`grep sample config/config.dat|cut -f2 -d'='`

if [ -d $collection ] ; then
	cont=`ls $collection|wc -l`
else
	echo "$collection not found"
	read a
	exit
fi

if [ $cont -gt 0 ] ; then
	rm $collection/*
fi

for class in `ls $classpath/*`
	do
	nfiles=`ls $class`
	cpfiles=`echo "$nfiles/$sample"|bc -l`
		do
		echo $class
		exit
		done
	done
