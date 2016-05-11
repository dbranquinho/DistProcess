#!/bin/bash

lemmafile=`grep lemmafile config/config.dat|cut -f2 -d'='`
if [ "$lemmafile" == "" ] ; then
        echo "ERROR - There is no lemma file defined into config file"
        exit
fi

if [ -f temp/$1 ] ; then
	rm temp/$1
fi

touch temp/$1

for linha in `cat acervo/$1`
	do
	if [ `echo $linha|wc -c` -gt 3 ] ; then
		stop=`grep -awm1 $linha $lemmafile`
		if [ `echo $stop |wc -c` -gt 3 ] ; then
			echo $stop|cut -f1 -d';' >> temp/$1
		else 
			echo $linha >> temp/$1
		fi
	fi
	done
cp temp/$1 acervo/$1

