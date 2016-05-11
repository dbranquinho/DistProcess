#!/bin/bash

### Bath kMeans ### from Jacob Kogan - Introduction to Clustering Large and High-dimensional data
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  PREPARATION to RUN ######################

if [ $# -lt 2 ] ; then
        echo -e "`date` - $0: Sintax:\n$0 node_number init\nInit can be:\n0 - Initialize all cluster\n1 - Continue after the last run"
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
collection=`grep collection config/config.dat|cut -f2 -d'='`
if [ "$collection" == "" ] ; then
	echo "`date` - $0: ERROR - collection not difined"
	exit
fi
distance=`grep distance config/config.dat|cut -f2 -d'='`
if [ "$distance" == "" ] ; then
	echo "`date` - $0: ERROR - distance not difined"
	exit
fi
tol=`grep tolerance config/config.dat|cut -f2 -d'='`
if [ "$tol" == "" ] ; then
	echo "`date` - $0: ERROR - tolerance not difined ($tol)"
	exit
fi

# Show how many cluster came from config file
echo "`date` - $0: Working with $ncluster clusters"
nr_t=`ls index/*.txt.idx|wc -l`
if [ $nr_t -eq 0 ] ; then
	echo "`date` - $0: There are no files indexed into index directory"
	exit
fi

# Creating Centroids at first time
cont=0
setfileaux=`cat config/files$1.dat|wc -l`
setfile=`echo "scale=0; $setfileaux/$ncluster"|bc -l`
ctfile=0
if [ "$2" == "0" ] && [ "$1" == "1" ] ; then
	rm temp/*
	if [ ! -d similarity ] ; then
		mkdir similarity
	else
		rm -rf similarity
		mkdir similarity
	fi
	rm -rf index/cluster*
	echo "`date` - $0: Creating the first centroids"
	for files in `cat config/files$1.dat|cut -f2 -d';'`
		do
		ctfile=$((ctfile+1))
		if [ $ctfile -lt $setfile ] ; then
			continue
		fi	
		ctfile=0
		cont=$((cont+1))
		if [ ! -d index/cluster$cont ] ; then
			mkdir index/cluster$cont
		fi
		cp index/$files.idx index/cluster$cont/centroid.ctr
		echo "`date` - $0: centroid $cont"
		if [ $cont -eq $ncluster ] ; then
			break
		fi
		done
	echo "`date` - $0: Clusterizing documents from $collection"
	if [ -d index.bkp ] ; then
		if [ `ls index.bkp|wc -c` -gt 0 ] ; then
			rm -rf index.bkp/*
		fi
	else
		mkdir index.bkp
	fi
	echo "`date` - $0: Creating Stop Running Conditions"
	for centroid in `ls index| grep cluster`    # read all cluster directory to create a backup
		do                                  # if no more changes, than stop running
		if [ ! -d index.bkp/$centroid ] ; then
			mkdir index.bkp/$centroid
		fi
		cp index/$centroid/centroid.ctr index.bkp/$centroid
		done
	echo "`date` - $0: Cleaning cluster directory"
	for cluster in `ls index|grep cluster`
		do
		if [ `ls index/$cluster|wc -l` -gt 1 ] ; then
			echo "`date` - $0: Cleaning $cluster"	
			rm index/$cluster/*.txt.idx
		fi
		done
	echo "`date` - $0: Clusterizing all documents"
	rm nodes/node1.ctl
	rm temp/lock*
fi
if [ "$2" == "1" ] && [ "$1" == "1" ] ; then
	if [ -f nodes/node$1.ctl ] ; then
		rm nodes/node1.ctl
	fi
fi

# All nodes waiting the first node create the first centroids
while [ -f nodes/node1.ctl ] ;
        do
        echo "`date` - $0: NODE$1: Waiting for node1 create first centroids"
        sleep 5
        done


## Var to sim()
similarity=1
count_sim=0
cluster_choice=0

####### FUNCTIONS #################################
# Looking for Similarity file with centroids, all of then
function sim() {

similarity=1

if [ "$distance" == "cosine" ] ; then
	similarity=0
fi
if [ "$distance" == "euclidean" ] ; then
	similarity=99999999999999
fi
if [ $similarity -eq 1 ] ; then
	echo "`date` - $0: ERROR - There is no distance set"
	exit
fi

count_sim=0
cluster_choice=0
sim=0
for centroid in `ls index |grep cluster` # create a increment number to read index/cluster$centroid/centroid.ctr
	do                               # $centroid is c(i)={
	a=0
	b=0
	c=0
	for cfile in `cat index/$centroid/centroid.ctr`     		  # Reading document weight to compute with centroid
		do                					  # for a new vector centroid
		term=`echo $cfile|cut -f1 -d';'`                          # get term to looking for the same value from centroid
		tfidf_centroid=`echo $cfile|cut -f2 -d';'`                # get value tfidf from centroid
		lfile=`grep -awm1 $term index/$1`
		tfidf_query=`echo $lfile|cut -f2 -d';'`           	  # get tfidf from query file to compare with centroid
		if [ "$tfidf_query" == "" ] ; then                        # data consistency
			tfidf_query=0
		fi	
		if [ `echo $tfidf_query |wc -c` -gt 0 ] ; then                            # data consistency
			if [ "$distance" == "cosine" ] ; then
				a=`echo "scale=16; $a+($tfidf_query*$tfidf_centroid)"|bc -l`        # calc   xi*yi
				b=`echo "scale=16; $b+($tfidf_query*$tfidf_query)"|bc -l`           # calc   xi^2
				c=`echo "scale=16; $c+($tfidf_centroid*$tfidf_centroid)"|bc -l`     # calc   yi^2
			else
				a=`echo "scale=16; $tfidf_centroid"|bc -l`                          # sum to calc quadratic
				b=`echo "scale=16; $tfidf_query"|bc -l`                             # distance and centroids
				c=`echo "$c+($a - $b)^2" |bc -l`
			fi
		else
			echo "`date` - $0: ERROR - [$centroid][$cfile;$lfile]"
			exit
		fi
		done
	if [ "$distance" == "cosine" ] ; then
		if [ `echo "$a > 0" |bc` -gt 0 ] || [ `echo "$b > 0" |bc` -gt 0 ] ; then
			sim=`echo "$a/(sqrt($b)*sqrt($c))"|bc -l`           # calc (xi*yi)/(sqrt(xi) * sqrt(yi))
			count_sim=$((count_sim+1))
		fi
		if [ `echo "$sim > $similarity"|bc` -gt 0  ] ; then         # remember the bigger similarity
			similarity=$sim
			cluster_choice=$count_sim
		fi
	else
		count_sim=$((count_sim+1))
		sim=`echo "sqrt($c)" |bc -l`
		if [ `echo "$similarity > $sim"|bc` -gt 0  ] ; then         # remember the bigger similarity
			similarity=$sim
			cluster_choice=$count_sim
		fi
	fi
	if [ ! -f similarity/cluster$1-$cluster_choice ] ; then
		touch similarity/cluster$1-$cluster_choice
		echo 0 > similarity/cluster$1-$cluster_choice
	fi	
	
	max_sim=`cat similarity/cluster$1-$cluster_choice`
	if [ `echo "$sim > $max_sim" |bc` -gt 0 ] ; then
		echo $sim > similarity/cluster$1-$cluster_choice
	fi
	echo -e ".\c"
	done

}

function recalc_Centroids() {

echo -e " Recalculating centroid $1\r"

cat index/cluster$1/* |cut -f1 -d';'|sort|uniq >temp/centroid$3.uniq   # creating a uniq file terms to new vector centroid

for term in `cat temp/centroid$3.uniq` # read all cluster directory and re calculate centroids files
	do
	tfidf_centroid=`grep -awm1 $term index/cluster$1/centroid.ctr|cut -f2 -d';'`
	if [ "$tfidf_centroid" == "" ] ; then
		tfidf_centroid=0
	fi
	tfidf_query=`grep -awm1 $term index/$2|cut -f2 -d';'`
	if [ "$tfidf_query" == "" ] ; then
		tfidf_query=0
	fi
	total=`ls index/cluster$1|wc -l`
	if [ $total -gt 0 ] ; then
		means=`echo "scale=16; $tfidf_centroid+(1/$total)*($tfidf_query-$tfidf_centroid)"|bc -l`
		echo "$term;$means"  >> temp/centroid$3.ctr    
	else
		echo "`date` - $0: ERRO: total terms on centroid is zero for term $term in cluster $1"
		exit
	fi
	done
mv temp/centroid$3.ctr index/cluster$1/centroid.ctr
rm temp/centroid$3.uniq

}


### MAIN #####################
# 

if [ -f run/node$1/run.log ] ; then
	step=`cat run/node$1/run.log|grep -w "*** Step" |wc -l`
else
	step=0
fi
if [ -f config/files$1.dat ] ; then
	nfiles=`cat config/files$1.dat|wc -l`
else
	echo "`date` - $0: File config/files$1.dat not found"
	exit
fi
flag=1
while [ $flag -eq 1 ] ; do
	one=0
	while [ `ls nodes|grep endNode|wc -l` -gt 0 ] ; do              # This while trap all nodes to wait ultil last node
		if [ -f nodes/endNode$1 ] ; then                        # get this positon.
			rm nodes/endNode$1                              # After all nodes remove the endNode?
		fi                                                      # the new step get run for all nodes 
		if [ $one -eq 0 ] ; then
			echo -e "\n`date` - $0: Waiting others to start new step ($1)"
			one=1
		fi
		sleep 5
		done
	if [ -f nodes/finishNodes ] ; then                              # sure to finish step terminated
		rm nodes/finishNodes
	fi
	step=$((step+1))
	echo -e "\n\n`date` - $0: *** Step $step "
	ctfiles=0
	for files in `cat config/files$1.dat|cut -f2 -d';'`
		do
		files=`echo $files.idx`
		ctfiles=$((ctfiles+1))
		echo -e "file $ctfiles/$nfiles \c"
		sim $files                                          # function to calculate similarity
		if [ `echo $cluster_choice |wc -c` -eq 0 ] || [ "$cluster_choice" == "0" ] ; then
			echo -e "\n`date` - $0: ERROR - ($files) There is no similarity with anyone"
			exit
		fi
		if [ -f temp/cluster$cluster_choice ] ; then        # Verify if the cluster is locked
			one=0
			while [ -f temp/cluster$cluster_choice ] ;  # if yes, than wait 5 seconds to test again
				do                                  # you can change this time wait
				if [ $one -eq 0 ] ; then
					echo -e "`date` - $0: Waiting about cluster$cluster_choice to recalculate new vector"
					one=1
				fi
				sleep 5
				done
		fi
		echo $1 > temp/cluster$cluster_choice             # lock the cluster for other distributed process
		cp index/$files index/cluster$cluster_choice      # copy chosen file to respective cluster
		echo -e "\n`date` - $0: $files->$cluster_choice"
		recalc_Centroids $cluster_choice $files $1        # recalculate centroids ($1 is the node)
		rm temp/cluster$cluster_choice                    # remove lock to cluster
		done	
################################################################################
# The special conditions to stop running must be sincronized with all nodes
# when one node get here, other nodes waiting. When all nodes finished
# node1 verify if stop conditions was satisfied, if yes, then all nodes stop run
# if stop running conditions not satisfied, then all nodes start running again
###############################################################################
	touch nodes/endNode$1                           # mark node as finished and wait for others
	while [ ! -f nodes/finishNodes ] ;              # loop to wait
			do                                    
			one=0
			if [ $n_nodes -gt 1 ] ; then
				if [ $one -e1 0 ] ; then
					echo -e "\n`date` - $0: Waiting node$1 waiting other to see stop running conditions($n_nodes)"
					one=1
				fi
				sleep 10 
			else
				break
			fi
			if [ `ls nodes |grep end|wc -l` -eq $n_nodes ] && [ "$1" == "1" ] ; then
				break
			fi
			done
	if [ -f nodes/finishNodes ] ; then
		flag=`cat nodes/finishNodes`
	fi
	if [ "$1" == "1" ] ;  then
		flag=0
		echo -e "`date` - $0: Node$1 looking for stop running conditions"
		for centroid in `ls index| grep cluster`       # loop to verify stop running from nextBKM(C)
                	do                                     # if centroid not moved, then finish process
                	for term in `cat config/term.dat|cut -f2 -d';'`
                        	do
                        	diff1=`grep -awm1 $term index/$centroid/centroid.ctr|cut -f2 -d';'`
                        	diff2=`grep -awm1 $term index.bkp/$centroid/centroid.ctr|cut -f2 -d';'`
				if [ "$diff1" == "" ] || [ "$diff2" == "" ] ; then
					continue
				fi
				if [ `echo "$diff1 > $diff2"|bc` -gt 0 ] ; then
                        		diff=`echo "scale=16; $diff1-$diff2"|bc -l`
				else
                        		diff=`echo "scale=16; $diff2-$diff1"|bc -l`
				fi
                        	if [ `echo "$diff > $tol" |bc` -gt 0 ] ; then    # stop running condition not found
                                	flag=1
                                	echo "Q($centroid) - Q(nextBKM($centroid) = $diff > $tol"
                        		cp index/$centroid/centroid.ctr index.bkp/$centroid
					if [ $n_nodes -gt 1 ] ; then
						echo "1" > nodes/finishNodes
					fi
					break
                        	fi
                        	done                                                # End to loop to look Terms diff
			if [ $flag -eq 1 ] ; then
				rm index/$centroid/*.txt.idx
				break
			fi
			done                                                        # End to loop to Centroid diff
	fi
	done
if [ "$1" == "1" ] ; then
	echo "0" > nodes/finishNodes
	echo -e "`date` - $0: Find out the conditions to stop run (END $diff - $tol)"
else
	echo -e "`date` - $0: Find out the conditions to stop run (END=`cat nodes/finishNodes`)"
fi
