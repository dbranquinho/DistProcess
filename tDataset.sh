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

# preparing directories and files to hold dataset
if [ "$1" == "1" ] ; then
	echo "`date` - $0: Cleaning to inicial state on node$1"
	if [ ! -f nodes/node1.ctl ] ; then
		touch nodes/node1.ctl
	fi	
	if [ -d acervo ] ; then
		echo "`date` - $0: Removing old collection files"
		rm -rf acervo
	fi
	
	if [ -d temp ] ; then
		rm -rf temp
	fi
	
	if [ -d config ] ; then
		if [ -f config/term.dat ] ; then
			echo "`date` - $0: Removing old Terms files"
			rm config/term*.dat 2>&1
		fi
		if [ -f config/files.dat ] ; then
			echo "`date` - $0: Removing old File files"
			rm config/files*.dat  2>&1
		fi
	fi
	if [ -d index ] ; then
		rm -rf index
	fi
	mkdir temp index acervo
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

#####################
## Run dataset              Ignore if you don't work, this routine just show the sample
#####################
if [ "$collection" == "datatest" ] ; then
	echo "`date` - $0: Dataset is a sample, no process will be start, just a copy"
	echo "`date` - $0: You don't need to run tNi.sh or tIndex.sh, just run cCluster.sh"
	echo "`date` - $0: Creating collection"
	for files in `ls $collection`
		do
		cp datatest/$files index/$files.idx
		cp datatest/$files acervo/$files
                done
	cat acervo/* >temp/terms.aux
	for lterm in `cat temp/terms.aux|cut -f1 -d';'`
		do
		echo $lterm >>temp/terms1.aux	
		done
		
	cat temp/terms1.aux|sort|uniq >temp/terms.aux
	rm temp/terms1.aux
	ind_t=0
	cont=0
	nr_t=`cat temp/terms.aux|wc -l`
	echo "`date` - $0: Creating terms"
        for terms in `cat temp/terms.aux|cut -f1 -d';'`
                do
                ind_t=$((ind_t+1))
                echo "$ind_t;$terms" >> config/term.dat
                cont=$((cont+1))
                echo -e "`echo "scale=1; (100*$cont)/$nr_t"|bc -l`\r\c"
		done
	cp config/term.dat config/term1.dat
	rm temp/terms.aux
	echo "`date` - $0: Creating file with all file corpus"
	ind_t=0
	cont=0
	rm config/files.dat
	touch config/files.dat
	for files in `ls acervo`
		do
		cont=$((cont+1))
		echo "$cont;$files" >> config/files.dat
		linha=`cat acervo/$files|tr -s '\n' ' '`
		echo "$files;$linha" >>index/files.idx
		done
	cp index/files.idx index/files1.idx
	cp config/files.dat config/files1.dat
	./tNi.sh 1
	cp index/ni1.idx index/ni.idx
	exit
fi

################ END Sample #########################

# Creating loock for all nodes to prevent node1 to run forward before other nodes go to the end
if [ "$1" != "1" ] ; then
	touch nodes/node$1.ctl
fi

# Create split files
if [ "$1" == "1" ] ; then
	# Total files found in collection
	N=`ls $collection|wc -l`

	echo "`date` - $0: Spliting files on $collection for distribution process"
	cont=0
	limit=$((N/n_node))
	ct_node=1
	for files in `ls $collection`
		do
		cont=$((cont+1))
		if [ $cont -gt $limit ] ; then
			cont=1
			ct_node=$((ct_node+1))
			if [ $ct_node -gt $n_node ] ; then
				ct_node=1
			fi
		fi
		echo "$cont;$files" >> config/files$ct_node.dat
		done
	rm nodes/node1.ctl
fi

while [ -f nodes/node1.ctl ] ;
	do
	echo "`date` - $0: NODE$1: Waiting for split node1"
	sleep 10
	done


# cleaning data set from non reading chars and lemmatization of the terms
echo "`date` - $0: Reading files under acervo and cleaning data set"

for files in `cat config/files$1.dat|cut -f2 -d';'`
	do
	# Cleanning files from HTML Tags, non printing special chars and convert iso files to utf8
	iconv -f iso-8859-1 -t utf8 $collection/$files | tr [:upper:] [:lower:] | sed 's|<[^>]*>||g' | tr -s '+-:.,;•(){}<>*&$#@!_[]%?ºª+=\r\t\134\47\42\140\221\222\223\224\225\226\227\228\136\176\174' ' ' >acervo/$files
	if [ "$lemma" == "y" ] || [ "$lemma" == "s" ] ; then
		./lematizer.sh $files
	fi
	done

if [ "$1" == "1" ] ;  then
	echo -e "`date` - $0: node1 waiting for other nodes to cleaning dataset"
	while [ `ls nodes|grep node |wc -l` -gt 0 ] ;
		do
		echo -e "`date` - $0: Waiting for \n`ls nodes|grep node`"
		sleep 10
		done
else
	rm nodes/node$1.ctl
fi

# Creating file with all uniq terms into collection
if [ "$1" == "1" ] ;  then
	echo -e "`date` - $0: Creating Terms ..."
	cat acervo/*|tr -s ' ' '\n' |sort|uniq >temp/terms.aux
	
	
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
