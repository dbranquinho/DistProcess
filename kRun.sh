#!/bin/bash
### Script to kill remote process
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

for pro in `ps -ef|grep -w $1 |tr -s ' ' ';'|cut -f2,3 -d';'`
	do
	sf=`echo $pro|cut -f1 -d';'`
	if [ "$sf" == "" ] ; then
		proc=`echo $pro|cut -f2 -d';'`
		echo "(1)killing process $proc"
		kill -9 $proc
	else
		proc=`echo $pro|cut -f1 -d';'`
		echo "(2)killing process $proc"
		kill -9 $proc
	fi
	done
