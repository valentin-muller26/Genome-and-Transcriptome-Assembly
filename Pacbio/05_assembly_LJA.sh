#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Assembly_LJA
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/Assembly_LJA_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/Assembly_LJA_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/05_assembly_LJA"
LOGDIR="$WORKDIR/log"
READFILEFILTERED="$WORKDIR/results/Pacbio/02_read_filtering/ERR11437310_filtered.fastq.gz"
APPTAINERPATH="/containers/apptainer/lja-0.2.sif"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

# Run Hifiasm assembly with PacBio HiFi reads
apptainer exec --bind /data "$APPTAINERPATH" lja \
    -o "$OUTDIR" \
    -t "$SLURM_CPUS_PER_TASK" \
    "$READFILEFILTERED"