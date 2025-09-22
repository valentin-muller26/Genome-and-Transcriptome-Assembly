#!/usr/bin/env bash
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=Fastp_Pacbio
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/FastpPacBio_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/FastpPacBio_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/02_read_filtering"
LOGDIR="$WORKDIR/log"
READFILE="$WORKDIR/data/Lu-1/ERR11437310.fastq.gz"
APPTAINERPATH="/containers/apptainer/fastp_0.24.1.sif"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

# Fastp for PacBio HiFi (single-end) without quality length and adapter filtering 
apptainer exec --bind /data "$APPTAINERPATH" fastp \
    -i "$READFILE" \
    -o "$OUTDIR/ERR11437310_filtered.fastq.gz" \
    -A -Q -L \
    -w "$SLURM_CPUS_PER_TASK" \
    -h "$OUTDIR/fastp_PacBio_Lu-1.html" \
    -j "$OUTDIR/fastp_PacBio_Lu-1.json"