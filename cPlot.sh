#!/bin/bash

### Create plot file and command to use gnuplot
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###

### Variables
max_sim=0

### Read max ditance from centroid

function sim() {
mix_sim=0
for linha in `./simIntraCluster.sh $1|tr -s ' ' ';'`
	do
	weight=`echo $linha|cut -f4 -d';'`
	if [ `echo "$max_sim<$weight"|bc` -gt 0 ] ; then
		max_sim=$weight
	fi
	done
}



###  MAIN ####

echo -e "Creating plot configuration"
if [ -d dataplot ] ; then
	rm -rf dataplot
	mkdir dataplot
fi
count=0
echo "set xlabel 'x1'" > cmd.plot
echo "set ylabel 'x2'" >> cmd.plot
echo "set xrange [0:8]" >> cmd.plot
echo "set yrange [0:8]" >> cmd.plot
echo "set title 'Dataset Graph CLuster Distribution'" >> cmd.plot
echo "set term x11 persist font arial" >> cmd.plot
echo "set grid xtics " >> cmd.plot
echo "set grid ytics" >> cmd.plot
ct=0
echo "Runing files"
for files in `ls index/*.txt.idx`
	do
	basename=`echo $files|cut -f2 -d'/'`
	basename=`echo $basename|cut -f1,2 -d'.'`
	if [ $ct -eq 0 ] ; then
		ct=1
		echo "plot 'dataplot/$basename.plot' using 2:1  lw 4 title '$basename'" >>cmd.plot
	else
		echo "replot 'dataplot/$basename.plot' using 2:1  lw 4 title '$basename'" >>cmd.plot
	fi
	count=0
	for term in `cat config/term.dat|cut -f2 -d';'`
		do
		count=$((count+1))
		if [ $count -gt 2 ] ; then
			break
		fi
                col=`grep -awm1 $term $files|cut -f2 -d';'`
		if [ ! -f dataplot/$basename.plot ] ; then
			touch dataplot/$basename.plot
		fi
                echo -e "$col \c" >> dataplot/$basename.plot
		done
        #echo -e "\n" >>dataplot/$basename.plot
	done
n_cluster=`grep cluster config/config.dat|cut -f2 -d'='`
echo "Creating $n_cluster clusters"
for cluster in `seq 1 $n_cluster`    # loop to create centroids to plot
        do
	sim $cluster
	max_sim=`echo "$max_sim+.1"|bc`
	echo "replot 'dataplot/cluster$cluster.plot' using 2:1  lc 'black' lw 4 title 'cluster$cluster'" >>cmd.plot
	echo "replot 'dataplot/cluster$cluster.plot' using 2:1:($max_sim)  with circle lw 2 notitle" >>cmd.plot
	count=0
        for term in `cat config/term.dat|cut -f2 -d';'`
                do
		count=$((count+1))
		if [ $count -gt 2 ] ; then
			break
		fi
                col=`grep -awm1 $term index/cluster$cluster/centroid.ctr|cut -f2 -d';'`
		if [ ! -f dataplot/cluster$cluster.plot ] ; then
			touch dataplot/$centroid.plot
		fi
                echo -e "$col \c" >> dataplot/cluster$cluster.plot
                done
        #echo -e "\n" >>dataplot/cluster$cluster.plot
        done
touch dataplot/mainCentroid.plot
count=0
for mainCentroid in `cat index/mainCentroid.idx`
	do
	count=$((count+1))
	if [ $count -gt 2 ] ; then
		break
	fi
        col=`echo $mainCentroid |cut -f2 -d';'`
        echo -e "$col \c" >> dataplot/mainCentroid.plot
	done
echo -e "" >dataplot/line.plot
echo "replot 'dataplot/mainCentroid.plot' using 2:1  with circles lc 'blue' fs transparent solid 0.15 noborder title 'MainCentroid'" >>cmd.plot
for cluster in `seq 1 $n_cluster`
	do
	cat dataplot/mainCentroid.plot dataplot/line.plot dataplot/cluster$cluster.plot > dataplot/mainCentroid_l$cluster.plot
	echo "replot 'dataplot/mainCentroid_l$cluster.plot' using 2:1 with lines lc 'blue' notitle" >>cmd.plot
	done
gnuplot cmd.plot

