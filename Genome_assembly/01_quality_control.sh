#!/usr/bin/env bash
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=FastQC_Pacbio
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/FastqcPacbio_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/FastqcPacbio_%J.err
#SBATCH --partition=pibu_el8


#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR=$WORKDIR/results/Pacbio/01_quality_control
LOGDIR="$WORKDIR/log"
READFILE=$WORKDIR/data/Lu-1/ERR11437310.fastq.gz
APPTAINERPATH="/containers/apptainer/fastqc-0.12.1.sif"

#Create the directory for the error and output file if not present
mkdir -p $LOGDIR


#Create the directory output if not present
mkdir -p $OUTDIR

#run fastqc with the number of thread indicated for SLURM for the reads and put the result in the outdir (-o $OUTDIR)
apptainer exec --bind /data $APPTAINERPATH fastqc -t $SLURM_CPUS_PER_TASK $READFILE -o $OUTDIR
