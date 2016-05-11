#!/bin/bash

### Bath kMeans ### from Jacob Kogan - Introduction to Clustering Large and High-dimensional data
### Calculate Main Centroid
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  PREPARATION to RUN ######################

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
if [ -f index/mainCentroid.idx ] ; then
	rm index/mainCentroid.idx
fi
touch index/mainCentroid.idx

for centroid in `seq 1 $ncluster`
        do
        cat index/cluster$centroid/centroid.ctr >> temp/mainCentroid.idx
        done

cat temp/mainCentroid.idx |cut -f1 -d';'|sort|uniq >temp/mainCentroid.uniq   # creating a uniq file terms to new vector centroid
rm temp/mainCentroid.idx
echo "Processing Main Centroid from $ncluster Clusters"
for term in `cat temp/mainCentroid.uniq` # read all cluster directory and re calculate centroids files
	do
	a=0
	for cluster in `seq 1 $ncluster`
		do
		tfidf_centroid=`grep -awm1 $term index/cluster$cluster/centroid.ctr|cut -f2 -d';'`
		if [ "$tfidf_centroid" == "" ] ; then
			tfidf_centroid=0
		fi
		a=`echo "$a+$tfidf_centroid" |bc -l`
		done
	echo "$term;`echo "$a/$ncluster"|bc -l`" >>index/mainCentroid.idx
	done
