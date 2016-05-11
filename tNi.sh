#!/bin/bash
### Creating a Ni file to support index file to create tf-idf weight
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####
n_node=`grep n_node config/config.dat|cut -f2 -d'='`
if [ "$n_node" == "" ] ; then
        echo "`date` - $0: ERROR - There is no number of nodes to work together"
        exit
fi

echo "`date` - $0: Initiating"

if [ -f index/ni.idx ] ; then
	rm index/ni.idx
fi
touch index/ni.idx

echo "`date` - $0: Reading Terms and creating ni file"
for lterm in `cat config/term.dat`
	do
	term=`echo $lterm|cut -f2 -d';'`	
	ni=`grep -w $term index/files.idx |wc -l`
	if [ $ni -eq 0 ] ; then
		echo "`date` - $0: ERROR: ni of $term is $ni"
	else
		echo "$term;$ni" >> index/ni.idx
	fi
	done
sort -k1 -t';' index/ni.idx |uniq > temp/ni.idx
mv temp/ni.idx index/ni.idx
echo "`date` - $0: Done!"
