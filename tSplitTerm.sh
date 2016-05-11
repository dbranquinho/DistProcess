#!/bin/bash

# Get some informations from config file
collection=`grep collection config/config.dat|cut -f2 -d'='`
if [ "$collection" == "" ] ; then
        echo "ERROR - There is no collection defined into config file"
        exit
fi
n_node=`grep n_node config/config.dat|cut -f2 -d'='`
if [ "$n_node" == "" ] ; then
        echo "ERROR - There is no number of nodes to work together"
        exit
fi

# Total files foound in collection
N=`cat config/term.dat|wc -l`

echo Spliting file terms for distribution process
cont=0
limit=$((1+(N/n_node)))
ct_node=1

if [ ! -f config/term.dat ] ; then
	echo "config/term.dat not found"
	exit
fi

for nodo in `seq 1 $n_node`
	do
	if [ -f config/term$nodo.dat ] ; then
		rm config/term$nodo.dat
	fi
	done

for lterm in `cat config/term.dat`
        do
        cont=$((cont+1))
        if [ $cont -gt $limit ] ; then
                cont=1
                ct_node=$((ct_node+1))
                if [ $ct_node -gt $n_node ] ; then
                        ct_node=1
                fi
        fi
        echo $lterm  >> config/term$ct_node.dat
        done

