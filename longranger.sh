#!/bin/bash/

############################
# This is a pipeline for longranger wgs on Graham CC server
# Needs to be started from a directory containing fastqs demultiplexed with bcl2fastq
############################

homedir=$1
fastqdir=$2
index=$3


mkdir bash_files

genome_dir=$MUGQIC_INSTALL_HOME/genomes/species
genomefirstdir=$(echo "$genome_dir/$(ls ${MUGQIC_INSTALL_HOME}/genomes/species/ | grep -e "$index")/genome/10xGenomics")
genome=$(echo "$genomefirstdir/$(ls $genomefirstdir | grep -v -e "cellranger")")
bash=bash_files

for i in $(ls $fastqdir | awk -F "_R[0-9]" '{print $1}' | uniq); do
        echo "creating bash file for sample ${i}";
       	cd $fastqdir
       	mkdir $i
	mv `find $fastqdir -maxdepth 1 -type f | grep -e $i` $i
	
	cd $homedir
	echo "#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --job-name=longranger_${i}
#SBATCH --output=%x-%j.out
#SBATCH --error %x-%j.err
#SBATCH --ntasks=12
#SBATCH --mem-per-cpu=6G
#SBATCH --mail-user=$JOB_MAIL
#SBATCH --mail-type=END, FAIL
#SBATCH --A=$SLURM_ACCOUNT
	
cd $homedir
echo 'start date'
date
module load mugqic/longranger
longranger wgs --id $i --fastqs ${fastqdir}${i} --vcmode freebayes --reference $genome --localcores 12 --localmem 72">${bash}/${i}_longranger.sh;

sbatch ${bash}/${i}_longranger.sh;

sleep 1;
done

