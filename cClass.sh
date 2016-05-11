#!/bin/bash

### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
### Create Cetnroid from a know Class - Part of test
###  PREPARATION to RUN ######################

if [ $# -lt 1 ] ; then
        echo -e "`date` - $0: Sintax:\n$0 node_number"
        exit
fi
if [ ! -d index-Class ] ; then
	mkdir index-Class
fi

ctrain=`grep ctrain config/config.dat|cut -f2 -d'='`
if [ "$ctrain" == "" ] ; then
	echo "`date` - $0: ERROR - ctrain not defined"
	exit
fi
n_nodes=`grep n_nodes config/config.dat|cut -f2 -d'='`
if [ "$n_nodes" == "" ] ; then
	echo "`date` - $0: ERROR - Number of nodes not defined"
	exit
fi
ncluster=`grep cluster config/config.dat|cut -f2 -d'='`
if [ "$ncluster" == "" ] ; then
	echo "`date` - $0: ERROR - Number of cluster not defined"
	exit
fi
class_dir=`grep class_dir config/config.dat|cut -f2 -d'='`
if [ "$class_dir " == "" ] ; then
	echo "`date` - $0: ERROR - Class directory not difined"
	exit
fi
distance=`grep distance config/config.dat|cut -f2 -d'='`
if [ "$distance" == "" ] ; then
	echo "`date` - $0: ERROR - distance not difined"
	exit
fi

# Show how many cluster came from config file
echo "`date` - $0: Working with $ncluster clusters"
nr_t=`ls index/*.txt.idx|wc -l`
if [ $nr_t -eq 0 ] ; then
	echo "`date` - $0: There are no files indexed into index directory"
	exit
fi

if [ ! -d classTemp ] ; then
	mkdir classTemp
fi

#
#  Recalc to new centroid class  ######################
#
function recalc_Centroids() {

while [ -f classTemp/lock_$1 ] ; do
	sleep 5
	done
touch classTemp/lock_$1
echo -e " Recalculating centroid class $1\r"

if [ ! -f index-Class/$1/centroid.ctr ] ; then
	cp index/$2 index-Class/$1/centroid.ctr
fi
if [ -f index/$2 ] ; then
	cp index/$2 index-Class/$1
else
	echo "`date` - ERROR - file $index/$2 not found"
fi
cat index-Class/$1/* |cut -f1 -d';'|sort|uniq >classTemp/ClassCentroid$3.uniq   # creating a uniq file terms to new vector centroid
total=$((`ls index-Class/$1|wc -l`-1))

for term in `cat classTemp/ClassCentroid$3.uniq` # read all cluster directory and re calculate centroids files
	do
	tfidf_centroid=`grep -awm1 $term index-Class/$1/centroid.ctr|cut -f2 -d';'`
	if [ "$tfidf_centroid" == "" ] ; then
		tfidf_centroid=0
	fi
	tfidf_query=`grep -awm1 $term index/$2|cut -f2 -d';'`
	if [ "$tfidf_query" == "" ] ; then
		tfidf_query=0
	fi
	if [ $total -gt 0 ] ; then
		means=`echo "scale=16; $tfidf_centroid+(1/$total)*($tfidf_query-$tfidf_centroid)"|bc -l`
		echo "$term;$means"  >> classTemp/ClassCentroid$3.ctr    
	else
		echo "`date` - $0: ERRO: total terms on centroid is zero for term $term in class $1"
		exit
	fi
	done
mv classTemp/ClassCentroid$3.ctr index-Class/$1/centroid.ctr
rm classTemp/centroid$3.uniq
rm classTemp/lock_$1

}


### MAIN #####################
# 
ct=0
nr_train=`cat config/files$3.dat|wc -l`
nr_train=`echo "scale=1; $nr_train*($ctrain/100)"|bc -l|cut -f1 -d'.'`

for files in `cat config/files$3.dat|cut -f2 -d';'`
	do
	# Identifing class
	class=`ls -R $class_dir/*/$files|tr -s '/' '\n'|tail -2|head -1`
	if [ ! -d index-Class/$class ] ; then
		mkdir index-Class/$class
	fi
	if [ ! -f index-Class/$class/centroid.ctr ] ; then
		touch index-Class/$class/centroid.ctr
	fi
	files=`echo $files.idx`
	recalc_Centroids $class $files $1        # recalculate centroids ($1 is the node)
	ct=$((ct+1))
	if [ $ct -gt 0 ] ; then
		exit
	fi
	done

