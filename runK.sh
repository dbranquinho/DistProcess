#!/bin/bash
### Script configuration system
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

n_nodes=`grep n_nodes config/config.dat|cut -f2 -d'='`
username=`grep username config/config.dat|cut -f2 -d'='`
homedir=`grep homedir config/config.dat|cut -f2 -d'='`

if [ "$1" == "-c" ] ; then
	echo "Clear log files..."
	rm -rf run
fi

if [ ! -d run ] ; then
	mkdir run
fi

echo "Creating commands to remote nodes"
cont=0
for nodes in `cat config/nodes.dat`
	do
	cont=$((cont+1))
	if [ ! -d node$cont ] ; then
		mkdir run/node$cont
		touch run/node$cont/run.log
	fi
	done

echo "Executing remote nodes shell"
echo "$username: $n_nodes"
cont=0
for nodes in `cat config/nodes.dat`
	do
	echo $nodes
	cont=$((cont+1))
	bash $homedir/config/lookForK.dat $cont $homedir >>run/node$cont/run.log&
	#ssh $username@$nodes $homedir/config/lookForK.dat $cont $homedir >>run/node$cont/run.log&
	done	
echo "Backgroud process started"
