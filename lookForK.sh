#!/bin/bash

### Bath kMeans ### from Jacob Kogan - Introduction to Clustering Large and High-dimensional data
### Calculate Main Centroid by Files
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  PREPARATION to RUN ######################

if [ $# -lt 2 ] ; then
        echo -e "Sintax:\n$0 node_number Precision (0-16)"
        exit
fi
if [ $2 -lt 0 ] || [ $2 -gt 16 ] ; then
        echo -e "Sintax:\n$0 Precision (1-16)"
        exit
fi

ncluster=`grep cluster config/config.dat|cut -f2 -d'='`
if [ "$ncluster" == "" ] ; then
	echo "`date` - $0: ERROR - Number of cluster not defined"
	exit
fi
distance=`grep distance config/config.dat|cut -f2 -d'='`
if [ "$distance" == "" ] ; then
	echo "`date` - $0: ERROR - distance not difined"
	exit
fi

### MAIN #####################
# 

touch nodes/node1.lock

# Create Centroid Zero - all coordinates are zero
if [ "$1" == "1" ] ; then
	echo "Creating zero Centroid"
	if [ -f index/zeroCentroid.ctr ] ; then
		rm index/zeroCentroid.ctr
	fi
	touch index/zeroCentroid.ctr
	for linha in `cat config/term.dat`
		do
		term=`echo $linha|cut -f2 -d';'`
		echo "$term;0" >> index/zeroCentroid.ctr
		done
	rm nodes/node1.lock
fi

while :
	do
	if [ -f nodes/node1.lock ] ; then
		continue
	fi
	break
	done
distance=`grep distance config/config.dat|cut -f2 -d'='`
if [ "$distance" == "" ] ; then
	echo "ERROR - distance not difined"
	exit
fi

	
## Var to sim()
similarity=1
count_sim=0
cluster_choice=0


# Looking for Similarity file with centroids, all of then

similarity=1

if [ "$distance" == "cosine" ] ; then
	similarity=0
fi
if [ "$distance" == "euclidean" ] ; then
	similarity=99999999999999
fi
if [ $similarity -eq 1 ] ; then
	echo "ERROR - There is no distance set"
	exit
fi

if [ -f config/distribution$1.dat ] ; then
	rm config/distribution$1.dat
fi

touch config/distribution$1.dat
echo "NODE$1: Looking for similarity between files"
ctfile=0
tfile=`cat config/files$1.dat|wc -l`
tterm=`cat index/zeroCentroid.ctr|wc -l`
for files in `cat config/files$1.dat|cut -f2 -d';'`
	do
	ctfile=$((ctfile+1))
	echo -e "$ctfile/$tfile\r\c"
	count_sim=0
	sim=0
	a=0
	aa=0
	b=0
	bb=0
	c=0
	cc=0
	for term in `cat index/zeroCentroid.ctr|cut -f1 -d';'`     	
		do                			
		tfidf_centroid=`grep -awm1 $term index/zeroCentroid.ctr|cut -f2 -d';'`
		tfidf_query=`grep -awm1 $term index/$files.idx |cut -f2 -d';'` 
		if [ "$tfidf_query" == "" ] ; then                        # data consistency
			tfidf_query=0
		fi	
		if [ "$tfidf_centroid" == "" ] ; then                        # data consistency
			tfidf_centroid=0
		fi	
		if [ `echo $tfidf_query |wc -c` -gt 0 ] ; then                            # data consistency
			#aa=`echo "scale=16; $aa+($tfidf_query*$tfidf_centroid)"|bc -l`     # calc   xi*yi
			bb=`echo "scale=16; $bb+$tfidf_query"|bc -l`        # calc   xi^2
			#cc=`echo "scale=16; $cc+($tfidf_centroid*$tfidf_centroid)"|bc -l`  # calc   yi^2
			a=`echo "scale=16; $tfidf_centroid"|bc -l`                        # sum to calc quadratic
			b=`echo "scale=16; $tfidf_query"|bc -l`                           # distance and centroids
			c=`echo "$c+($a - $b)^2" |bc -l`
		else
			echo "ERROR - [$term]"
			exit
		fi
		done
	sim1=`echo "$bb/$tterm"|bc -l`           # calc (xi*yi)/(sqrt(xi) * sqrt(yi))
	sim2=`echo "sqrt($c)" |bc -l`
	echo "$files;$sim1;$sim2" >> config/distribution$1.dat
	done
