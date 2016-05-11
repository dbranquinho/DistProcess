#!/bin/bash

### Plot Dataset Sample
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

echo Initiating
sample=`grep sample config/config.dat|cut -f2 -d'='`
if [ ! -d dataplot ] ; then
	echo "Sample not found"
	exit
fi
size=`ls  dataplot *.plot`
if [ `echo $size|wc -c` -gt 0 ] ; then
	rm dataplot/*.plot
fi

if [ ! -d dataplot ] ; then
	mkdir dataplot
fi

for files in `ls $sample`
	do
	for linha in `cat $sample/$files`
		do
		col=`echo $linha|cut -f2 -d';'`
		echo -e "$col \c" >> dataplot/$files.plot
		done
	echo -e "\n" >>dataplot/$files.plot
	done
gnuplot cmdSample.plot
echo "Done!"
