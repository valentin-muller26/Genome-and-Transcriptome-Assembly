#!/usr/bin/env bash
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=Fastp_RNASeq
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/FastpRNASeq_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/FastpRNASeq_%J.err
#SBATCH --partition=pibu_el8


#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/RNASeq/02_read_filtering"
LOGDIR="$WORKDIR/log"
RNAFILE_READ1="$WORKDIR/data/RNAseq_Sha/ERR754081_1.fastq.gz"
RNAFILE_READ2="$WORKDIR/data/RNAseq_Sha/ERR754081_2.fastq.gz"
APPTAINERPATH="/containers/apptainer/fastp_0.24.1.sif"

#Create the directory for the error and output file if not present
mkdir -p $LOGDIR


#Create the directory output if not present
mkdir -p $OUTDIR

# Illumina RNA-seq (paired-end)
apptainer exec --bind /data "$APPTAINERPATH" fastp \
  -i $RNAFILE_READ1 \
  -I $RNAFILE_READ2 \
  -o $OUTDIR/ERR754081_1.trimmed.fastq.gz \
  -O $OUTDIR/ERR754081_2.trimmed.fastq.gz \
  --thread $SLURM_CPUS_PER_TASK \
  --html $OUTDIR/fastp_RNASeq.html \
  --json $OUTDIR/fastp_RNASeq.json