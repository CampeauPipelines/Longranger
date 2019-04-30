#!/bin/bash/

############################
# This is a pipeline for longranger wgs on Graham CC server
# Needs to be started from a directory containing fastqs demultiplexed with bcl2fastq
############################

homedir=${pwd}
fastqdir=$1
cd $fastqdir

names=$(ls $fastqdir | awk -F "_R1" '{print $1}')

mkdir fastq_files

for i in $names; do
        mkdir fastq_files/$i;
        echo "name is ${i}";
        files=$(ls *.fastq.gz | grep -e "$i");

        for j in $files; do
                echo "file is ${j}";
                mv $j fastq/$i;
                echo "moving ${j} to ${i}";

        done

done

cd $homedir

mkdir bash_files

directories=$(ls fastq_files)
genome_dir=$MUGQIC_INSTALL_HOME/genomes/species
genome=$(echo "$genome_dir/$(ls ${MUGQIC_INSTALL_HOME}/genomes/species/ | grep -e $2)")
bash=bash_files
fastq=${home}/fastq_files

for i in $directories; do
        echo $i;
        echo "#!/bin/bash
        cd $home
        echo 'start date'
        date
        module load mugqic/longranger
        longranger wgs --id $i --fastqs ${fastq}/${i} --vcmode freebayes --reference $genome --localcores 12 --localmem 80">${bash}/${i}_longranger.sh;

        sbatch -A $SLURM_ACCOUNT --mail-type=END,FAIL --mail-user=$JOB_MAIL -J ${i}_longranger --time=72:00:0 --mem=80G -N 1 -n 12 ${bash}/${i}_longranger.sh;

        sleep 1;
done

