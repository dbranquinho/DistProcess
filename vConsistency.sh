#!/bin/bash

if [ ! -f $1 ] ; then
	echo $1 not found
	exit
fi
echo Verifying consistency of ni file
cont=0
sizet=`wc -l config/term.dat|cut -f1 -d' '`
sizeni=`wc -l index/ni.idx|cut -f1 -d' '`
echo "-> Initiating log ERROR <- `date`" >> config/consistency.err
echo "Term=$sizet" >> config/consistency.err
echo "NI=$sizeni" >> config/consistency.err

if [ $sizet -ne $sizeni ] ; then
	echo "The files, term and ni are differents, looking  for differences..." >config/consistency.err
else
	echo "There are no differences between the files term and ni" >config/consistency.err
fi

for lterm in `cat config/term.dat`
	do
	term=`echo $lterm|cut -f2 -d';'`	
	flag=`grep -awm1 $term index/ni.idx|cut -f1 -d';'|wc -c`
	if [ $flag -eq 0 ] ; then
		echo "ERROR: $term not found in ni file" >>config/consistency.err
               	ni=`grep -aw $term index/files.idx |wc -l`
               	echo "$term;$ni" >> index/ni.idx
	fi
	cont=$((cont+1))
	echo -e "`echo "scale=1;(($cont*100)/$sizet)" |bc -l`%\r\c"
	done
cont=0
for linha in `cat index/ni.idx`
	do
	tterm=`echo $linha|cut -f1 -d';'`	
	tf=`echo $linha|cut -f2 -d';'`	
	if [ $tf -eq 0 ] ; then
		echo "ERROR: $term equal zero in ni file" >>config/consistency.err
	fi
	cont=$((cont+1))
	echo -e "`echo "scale=1;(($cont*100)/$sizet)" |bc -l`%\r\c"
	done

ifiles=`ls index|grep txt.idx| wc -l`

if [ "$ifiles" == "" ] ; then
	ifiles=0
fi
if [ $ifiles -gt 0 ] ; then
	echo "Looking for differences between math numbers"
	for file in `ls index/*.txt.idx`
		do
		for linha in `cat $file` 
			do
			term=`echo $linha|cut -f1 -d';'`
			tfidf=`echo $linha|cut -f4 -d';'|cut -f1 -d'.'`
			if [ "$tfidf" == "" ] ; then
				echo "ERROR (tfidf) $file: $term;$ni;$tf;$tfidf" >> config/consistency.err
			fi
		done
	done
else
	echo "There is no index files, terminating"
fi
