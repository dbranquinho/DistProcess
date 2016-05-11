#!/bin/bash
### Create a index directory with weight to each termi for one file
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

if [ $# -eq 0 ] ; then
        echo -e "Sintax\n$0 file_name\n"
        exit
fi
echo Initiating

if [ ! -d index ] ; then
	echo "Index directory does not exists"
	exit
fi

echo Initiating variables
N=`wc -l config/files.dat|cut -f1 -d' '`
cont=0
echo Reading Terms and create weight

tni=`cat index/ni.idx|wc -l`
file=$1
echo -e "" > index/$file.idx
sfile=`grep -awm1 $file index/files.idx| cut -f2 -d';'`
echo -e "\nProcessing file $file \n"
for lni in `cat index/ni.idx`
	do
	cont=$((cont+1))
	per=`echo "scale=2; ($cont*100)/$tni"|bc -l`
	echo -e "$per  \r\c"
	term=`echo $lni |cut -f1 -d';'`
	tf=`echo $sfile | tr -s ' ' '\n' | grep -awm1 $term |wc -l`
	ni=`echo $lni |cut -f2 -d';'`
	if [ $ni -eq 0 ] ; then
		echo "ERRO: Term: $term, ni=$ni"
		exit
	fi
	if [ $tf -gt 0 ] ; then
		tfidf=`echo "(1+(l($tf)/l(2))) * (l($N/$ni)/l(2))" | bc -l`
		echo "$term;$tfidf" >> index/$file.idx
	fi
	done
echo -e "\nDone!"
