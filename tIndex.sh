#!/bin/bash
### Create a index directory with weight to each term
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

if [ $# -eq 0 ] ; then
        echo -e "`date` - $0: Sintax\n$0 node_number\n"
        exit
fi
echo "`date` - $0: Initiating node$1"

if [ ! -d index ] ; then
	echo "`date` - $0: Index directory does not exists"
	exit
fi

echo "`date` - $0: Initiating variables"
N=`wc -l config/files.dat|cut -f1 -d' '`
cont=0
echo "`date` - $0: Reading Terms and create weight"

ct_pid=0
lastfile=""

for lfile in `cat config/files$1.dat`
	do
	file=`echo $lfile|cut -f2 -d';'`
	if [ -f index/$file.idx ] ; then
		if [ `cat index/$file.idx |wc -l` -gt 0 ] ; then
			echo "`date` - $0: Skip $file"
			lastfile=$file
			continue
		fi
	fi
	
	if [ "$lastfile" != "" ] ; then
		echo -e "" > index/$lastfile.idx
		sfile=`grep -awm1 $lastfile index/files.idx| cut -f2 -d';'`
		echo -e "\n`date` - $0: Re-processing file $lastfile \c"
		for lni in `cat index/ni.idx`
			do
			term=`echo $lni |cut -f1 -d';'`
			tf=`echo $sfile | tr -s ' ' '\n' | grep -aw $term |wc -l`
			ni=`echo $lni |cut -f2 -d';'`
			if [ $ni -eq 0 ] ; then
				echo "`date` - $0: ERRO: Term: $term, ni=$ni"
				echo "The system was trapped here, use fuser -k nohup.out"
				read xyz
			fi
			if [ $tf -gt 0 ] ; then
				tfidf=`echo "(1+(l($tf)/l(2))) * (l($N/$ni)/l(2))" | bc -l`
				if [ `echo "$tfidf > 0"|bc -l` -gt 0 ] ; then
					echo "$term;$tfidf" >> index/$lastfile.idx
				fi
			fi
			done
		lastfile=""
	fi
	echo -e "" > index/$file.idx
	sfile=`grep -awm1 $file index/files.idx| cut -f2 -d';'`
	echo -e "\n`date` - $0: Processing file $file \c"
	for lni in `cat index/ni.idx`
		do
		term=`echo $lni |cut -f1 -d';'`
		tf=`echo $sfile | tr -s ' ' '\n' | grep -aw $term |wc -l`
		ni=`echo $lni |cut -f2 -d';'`
		if [ $ni -eq 0 ] ; then
			echo "`date` - $0: ERRO: Term: $term, ni=$ni"
			echo "The system was trapped here, use fuser -k nohup.out"
			read xyz
		fi
		if [ $tf -gt 0 ] ; then
			tfidf=`echo "(1+(l($tf)/l(2))) * (l($N/$ni)/l(2))" | bc -l`
			if [ `echo "$tfidf > 0"|bc -l` -gt 0 ] ; then
				echo "$term;$tfidf" >> index/$file.idx
			fi
		fi
		done
done
echo -e "`date` - $0: \nDone!"
