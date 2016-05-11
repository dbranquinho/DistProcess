#!/bin/bash
if [ $# -lt 3 ] ; then
	echo "Sintax: $0 tf ni N"
	exit
fi
tf=$1
ni=$2
N=$3

echo "(1+(l($tf)/l(2))) * (l($N/$ni)/l(2))"
tfidf=`echo "(1+(l($tf)/l(2))) * (l($N/$ni)/l(2))" | bc -l`
echo $tfidf
