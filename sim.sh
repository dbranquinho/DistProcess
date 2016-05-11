#!/bin/bash

### Bath kMeans ### from Jacob Kogan - Introduction to Clustering Large and High-dimensional data
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

if [ ! -d similarity ] ; then
	mkdir similarity
else
	rm -rf similarity
	mkdir similarity
fi

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

count_sim=0
sim=0
a=0
b=0
c=0
cat index/$1.idx index/$2.idx |cut -f1 -d';'|sort|uniq >temp/term.tmp
for term in `cat temp/term.tmp`     	
	do                			
	tfidf_centroid=`grep -awm1 $term index/$1.idx|cut -f2 -d';'`
	tfidf_query=`grep -awm1 $term index/$2.idx |cut -f2 -d';'` 
	if [ "$tfidf_query" == "" ] ; then                        # data consistency
		tfidf_query=0
	fi	
	if [ "$tfidf_centroid" == "" ] ; then                        # data consistency
		tfidf_centroid=0
	fi	
	if [ `echo $tfidf_query |wc -c` -gt 0 ] ; then                            # data consistency
		if [ "$distance" == "cosine" ] ; then
			a=`echo "scale=16; $a+($tfidf_query*$tfidf_centroid)"|bc -l`                                 # calc   xi*yi
			b=`echo "scale=16; $b+($tfidf_query*$tfidf_query)"|bc -l`                                    # calc   xi^2
			c=`echo "scale=16; $c+($tfidf_centroid*$tfidf_centroid)"|bc -l`                              # calc   yi^2
		else
			a=`echo "scale=16; $tfidf_centroid"|bc -l`                             # sum to calc quadratic
			b=`echo "scale=16; $tfidf_query"|bc -l`                                 # distance and centroids
			c=`echo "$c+($a - $b)^2" |bc -l`
		fi
	else
		echo "ERROR - [$term]"
		exit
	fi
	done
if [ "$distance" == "cosine" ] ; then
	if [ `echo "$a > 0" |bc` -gt 0 ] || [ `echo "$b > 0" |bc` -gt 0 ] ; then
		sim=`echo "$a/(sqrt($b)*sqrt($c))"|bc -l`           # calc (xi*yi)/(sqrt(xi) * sqrt(yi))
		count_sim=$((count_sim+1))
	fi
	if [ `echo "$sim > $similarity"|bc` -gt 0  ] ; then                    # remember the bigger similarity
		similarity=$sim
		cluster_choice=$count_sim
	fi
else
	count_sim=$((count_sim+1))
	sim=`echo "sqrt($c)" |bc -l`
fi

echo "Similarity = $sim"
rm temp/term.tmp
