#!/usr/bin/env bash
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=FastQC_RNASeq
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/FastqcRNASeq_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/FastqcRNASeq_%J.err
#SBATCH --partition=pibu_el8


#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR=$WORKDIR/results/RNASeq/01_quality_control
LOGDIR="$WORKDIR/log"
RNAFILE_READ1="$WORKDIR/data/RNAseq_Sha/ERR754081_1.fastq.gz"
RNAFILE_READ2="$WORKDIR/data/RNAseq_Sha/ERR754081_2.fastq.gz"
APPTAINERPATH="/containers/apptainer/fastqc-0.12.1.sif"

#Create the directory for the error and output file if not present
mkdir -p $LOGDIR


#Create the directory output if not present
mkdir -p $OUTDIR

#run fastqc with the number of thread indicated for SLURM for both read ($READ1 $READ2) and put the result in the outdir (-o $OUTDIR)
apptainer exec --bind /data $APPTAINERPATH fastqc -t $SLURM_CPUS_PER_TASK $RNAFILE_READ1 $RNAFILE_READ2 -o $OUTDIR
