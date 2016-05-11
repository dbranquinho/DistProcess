#!/bin/bash

### Bath kMeans ### from Jacob Kogan - Introduction to Clustering Large and High-dimensional data
### Plot Distribution
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  PREPARATION to RUN ######################
if [ $# -lt 2 ] ; then
        echo "Sintax:\n$0 Precision1 Precision2 (0-16)"
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
echo -e "Creating plot configuration"
count=0
echo "set ylabel 'Average Weight by Document'" > cmdCluster.plot
echo "set xlabel 'Distance from Zero Centroid'" >> cmdCluster.plot
echo "set title 'Dataset Graph CLuster Distribution'" >> cmdCluster.plot
echo "set term x11 persist font arial" >> cmdCluster.plot
echo "set grid xtics " >> cmdCluster.plot
echo "set xrange [0]" >> cmd.plot
echo "set yrange [0]" >> cmd.plot
echo "set grid ytics" >> cmdCluster.plot
echo "set boxwidth 0.2" >> cmdCluster.plot
ct=0
echo "Runing files"
#echo "plot 'dataplot/lookForK.plot' using 1:2  with boxes" >>cmdCluster.plot
echo "plot 'dataplot/lookForK.plot' using 1:2 lw 2" >>cmdCluster.plot
if [ -f dataplot/lookForK.plot ] ; then
	rm dataplot/lookForK.plot
fi
touch dataplot/lookForK.plot
for distribution in `cat config/distribution.dat`
	do
	count=$((count+1))
        val1=`echo $distribution|cut -f2 -d';'`
        vala=`echo $distribution|cut -f2 -d';'`
        val2=`echo $distribution|cut -f3 -d';'`
	val1=`echo "1+(10^$1*($val1))"|bc|cut -f1 -d'.'`
	val2=`echo "1+(10^$2*($val2))"|bc|cut -f1 -d'.'`
        echo "$val2 $val1" >> dataplot/lookForK.plot
	done
gnuplot cmdCluster.plot

