#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Assembly_Trinity
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/Assembly_Trinity_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/Assembly_Trinity_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/RNASeq/04_assembly_trinity"
LOGDIR="$WORKDIR/log"
RNAFILE_READ1_FILTERED="$WORKDIR/results/RNASeq/02_read_filtering/ERR754081_1.trimmed.fastq.gz"
RNAFILE_READ2_FILTERED="$WORKDIR/results/RNASeq/02_read_filtering/ERR754081_2.trimmed.fastq.gz"

# Load fastp
module load Trinity/2.15.1-foss-2021a

# Run Trinity for transcriptome assembly
Trinity \
    --seqType fq \
    --left "$RNAFILE_READ1_FILTERED" \
    --right "$RNAFILE_READ2_FILTERED" \
    --CPU "$SLURM_CPUS_PER_TASK" \
    --max_memory "64G" \
    --output "$OUTDIR" \