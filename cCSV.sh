#!/bin/bash

if [ "$1" == "" ] ; then
	echo "Sintax: $0 nr_bWord"
	exit
fi
collection=`grep -wm1 collection config/config.dat`
if [ ! -f config/config.dat ] ; then
	echo "ERROR - Config file not found!"
	exit
fi
if [ -f termsbycluster.csv ] ; then
	rm termsbycluster.csv
fi
echo -e "date;\c" >termsbycluster.csv
for term in `seq 1 $1`
	do
	echo -e "term$term;\c" >>termsbycluster.csv
	done
echo "files" >>termsbycluster.csv
for index in `ls |grep index-enem`
	do
	echo -e "`echo "$index"|cut -f3,4,5 -d'-'`;\c" >>termsbycluster.csv
	flag=1
	for lterm in `cat $index/*.txt.idx|sort -hrk2 -t';'|head -$1`
		do
		term=`echo $lterm|cut -f1 -d';'`
		tfidf=`echo $lterm|cut -f2 -d';'`
		if [ $flag -eq 1 ] ; then
			flag=0
			max=`echo "$tfidf*$1"|bc -l`
		fi
		if [ `echo "$tfidf>$max"|bc` -eq 0 ] ; then
			echo -e "$term;\c" >>termsbycluster.csv
		fi
		done
	echo "`ls $index/*.txt.idx|wc -l`" >>termsbycluster.csv
	done
echo "CSV created: termsbycluster.csv"
