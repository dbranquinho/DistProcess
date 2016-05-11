

### Script configuration system
### Author: Delermando Branquinho Filho - delermando@gmail.com
### LCAD - Laboratório de Computação de Alto Desempenho. - UFES http://www.lcad.inf.ufes.br/
###
###  MAIN ####

### Variables

function atConfig() {
var1=$1
var2=$2

if [ -f config/config.dat ] ; then
	mv config/config.dat config/config.bkp
fi
touch config/config.dat
flag=0
for linha in `cat config/config.bkp`
	do
	vlinha=`echo $linha|cut -f2 -d'='`
	wlinha=$vlinha
	if [ "$vlinha" == "$var2" ] ; then
		wlinha=`echo "$var2=$var1"`
		flag=1
	fi
	echo $wlinha >> config/config.dat
	done
if [ $flag -eq 0 ] ; then
	echo "$var2=$var1" >> config/config.dat
fi
}

while :
	do
	clear
	echo Initiating
	if [ -f config/files.dat ] ; then
		N=`wc -l config/files.dat|cut -f1 -d ' '`
	else
		N=0
	fi
	if [ -f config/term.dat ] ; then
		nterm=`wc -l config/term.dat|cut -f1 -d ' '`
	else
		nterm=0
	fi
	if [ -f index/ni.idx ] ; then
		ni=`wc -l index/ni.idx|cut -f1 -d ' '`
	else
		ni=0
	fi
	collection=`grep collection config/config.dat|cut -f2 -d'='`
	if [ ! -d $collection ] ; then
        	collection="$collection (not found)"
	fi
	
	classpath=`grep classpath config/config.dat|cut -f2 -d'='`
	if [ ! -d $classpath ] ; then
        	classpath="$classpath (not found)"
	fi
	sample=`grep sample config/config.dat|cut -f2 -d'='`
	if [ ! -d $sample ] ; then
        	sample="$sample (not found)"
	fi
	cluster=`grep cluster config/config.dat|cut -f2 -d'='`
	if [ "$cluster" == ""] ; then
		cluster=0
	fi
	lemma=`grep lemmatization config/config.dat|cut -f2 -d'='`
	if [ "$lemma" == ""] ; then
		lemma="n"
	fi
	lemmafile=`grep lemmafile config/config.dat|cut -f2 -d'='`
	if [ "$lemmafile" == ""] ; then
		lemmafile="not set"
	fi
	classdir=`grep classdir config/config.dat|cut -f2 -d'='`
	if [ "$classdir" == ""] ; then
		classdir="not set"
	fi
	stpwfile=`grep stpwfile config/config.dat|cut -f2 -d'='`
	if [ "$stpwfile" == ""] ; then
		stpwfile="not set"
	fi
	stpwproc=`grep stpwproc config/config.dat|cut -f2 -d'='`
	if [ "$stpwproc" == ""] ; then
		stpwproc="not set"
	fi
	tol=`grep tolerance config/config.dat|cut -f2 -d'='`
	if [ `echo $tol|wc -c` -eq 0 ] ; then
		tol="not set"
	fi
	indexed=`ls index/*.txt.idx|wc -l`
	clear

	echo "Clusterization - Informational Console System     - `date`"
	echo "Delermando@gmail.com           "
	echo " "
	echo -e "Collection size ......: $N           \t\t\tView E(x)xecution:" 
	echo -e "Collection Index.. ...: $indexed     \t\t\t     "    
	echo -e "Vector sized features.: $nterm            "   
	echo -e "Collection ...........: $collection       "  
	echo -e "Class Path ...........: $classdir"
	echo -e "Number of Clusters ...: $cluster    " 
	echo -e "Tolerance (tol) ......: $tol   " 
	echo -e "Lemmatiation .........: $lemma" 
	echo -e "Lemma File ...........: $lemmafile       " 
	echo -e "Stopwords process ....: $stpwproc     " 
	echo -e "Stopwords file........: $stpwfile     " 
	echo -e "Sample ...............: $sample       " 
	echo "                                          " 
	echo "Options:                                  " 
	echo -e "e - Edit configuration file         \t\t1 - Verify data Consistency "
	echo -e "2 - Run pre-processing              \t\t3 - Create Ni File "
	echo -e "4 - Build Weight and first centroids   \t\t5 - Build Clusters "
	echo -e "7 - Console 			     \t\t8 - Plot             h - HELP"
	echo "  "
	echo -e "\nOption : \c"
	read option
	case $option in
		"x" ) ./viewRun.sh
				;;
		"e" ) vi config/config.dat
				;;
		"h" ) clear
			more README.txt
			read a
				;;
		"1" ) vConsistebcy.sh
				;;
		"2" ) ./tDataset.sh
				;;
		"3" ) ./tNi.sh
				;;
		"4" ) ./tIndex.sh
				;;
		"5" ) ./cCluster.sh
				;;
		"6" ) ./tDataset.sh
			if [ "$sample" == "dataset" ] ; then
				break
			fi
			./tNi.sh
			./tIndex.sh
			./cCluster.sh
			./console.sh
				;;
		"7" ) ./console.sh
				;;
		"8" ) ./cPlot.sh
			gnuplot cmd.plot
	esac
	done
