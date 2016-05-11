#!/bin/bash

### Pre-processing collection files
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

if [ $# -eq 0 ] ; then
        echo -e "`date` - $0: Sintax\n$0 node_number\n"
        exit
fi
echo "`date` - $0: Initiating node$1"
if [ ! -d nodes ] ; then
	mkdir nodes
fi

cpid=0

# Get some informations from config file
collection=`grep collection config/config.dat|cut -f2 -d'='`
if [ "$collection" == "" ] ; then
	echo "`date` - $0: ERROR - There is no collection defined into config file"
	exit
fi
lemma=`grep lemmatization config/config.dat|cut -f2 -d'='`
if [ "$lemma" == "" ] ; then
	echo "`date` - $0: ERROR - There is no lemmatization defined into config file"
	exit
fi
lemmafile=`grep lemmafile config/config.dat|cut -f2 -d'='`
if [ "$lemmafile" == "" ] ; then
	echo "`date` - $0: ERROR - There is no lemma file defined into config file"
	exit
fi
if [ ! -f $lemmafile ] ; then
	echo "`date` - $0: ERROR - There is no $lemmafile file"
	exit
fi
stpwfile=`grep stpwfile config/config.dat|cut -f2 -d'='`
if [ "$stpwfile" == "" ] ; then
	echo "`date` - $0: ERROR - There is no stopwords defined into config file"
	exit
fi
n_node=`grep n_node config/config.dat|cut -f2 -d'='`
if [ "$n_node" == "" ] ; then
	echo "`date` - $0: ERROR - There is no number of nodes to work together"
	exit
fi
if [ ! -f $stpwfile ] ; then
	echo "`date` - $0: ERROR - There is no $stpwfile file"
	exit
fi
stpwproc=`grep stpwproc config/config.dat|cut -f2 -d'='`
if [ "$stpwfile" == "" ] ; then
	echo "`date` - $0: ERROR - There is no if stopwords process defined into config file"
	exit
fi

if [ ! -d $collection ] ; then
	echo "`date` - $0: Path [$collection] not found - `pwd&&ls collection`"
	exit
fi

if [ `ls $collection|wc -l` -eq 0 ] ; then
	echo "`date` - $0: Directory collection is empty"
	exit
fi

# Creating file with all uniq terms into collection
if [ "$1" == "1" ] ;  then
	echo -e "`date` - $0: Creating Terms ..."
	cat acervo/*|sort|uniq >temp/terms.aux
	
	
	if [ -f config/term.dat ] ; then
        	rm config/term.dat
	fi
	
	nr_t=`cat temp/terms.aux|wc -l`
	cont=0
	ind_t=0
	if [ "$wtpwproc" == "s" ] || [ "$stpwproc" == "y" ] ; then
		echo "`date` - $0: Stopwords processing"
		for terms in `cat temp/terms.aux`
        		do
        		ind_t=$((ind_t+1))
        		if [ `echo $terms|wc -c` -lt 5 ] ; then
                		continue
        		fi
			if [ `grep -awm1 $terms $stpwfile|wc -l` -eq 0 ] ; then
        			echo "$ind_t;$terms" >> config/term.dat
			fi
			cont=$((cont+1))
			echo -e "`echo "scale=1; (100*$cont)/$nr_t"|bc -l`\r\c"
        		done
	else
		echo "`date` - $0: No Stopwords processing"
		for terms in `cat temp/terms.aux`
        		do
        		ind_t=$((ind_t+1))
        		echo "$ind_t;$terms" >> config/term.dat
			cont=$((cont+1))
			echo -e "`echo "scale=1; (100*$cont)/$nr_t"|bc -l`\r\c"
        		done
	fi


	echo "`date` - $0: Creating file with all file corpus"
	cont=0
	for files in `ls $collection`
		do
		cont=$((cont+1))
		linha=`cat acervo/$files|tr -s '\n' ' '`
		if [ "$linha" == "" ] ; then
			linha="ERROR: There is no line in $files"
		fi
		echo "$files;$linha" >>index/files.idx
		echo "$cont;$files" >>config/files.dat
		done
	./tSplitTerm.sh
fi
echo "`date` - $0: Done!"
