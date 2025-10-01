#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Assembly_Flye
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/Assembly_Flye_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/Assembly_Flye_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/05_assembly_Flye"
LOGDIR="$WORKDIR/log"
READFILEFILTERED="$WORKDIR/results/Pacbio/02_read_filtering/ERR11437310_filtered.fastq.gz"
APPTAINERPATH="/containers/apptainer/flye_2.9.5.sif"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

# Run Flye assembly with PacBio HiFi reads
apptainer exec --bind /data "$APPTAINERPATH" flye \
    --pacbio-hifi "$READFILEFILTERED" \
    --threads "$SLURM_CPUS_PER_TASK" \
    --out-dir "$OUTDIR"