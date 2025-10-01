#!/usr/bin/env bash
#SBATCH --time=01:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=Kmer_analysis
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/JellyFish_Pacbio_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/JellyFish_Pacbio_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/04_kmer_analysis"
LOGDIR="$WORKDIR/log"
READFILE="$WORKDIR/data/Lu-1/ERR11437310.fastq.gz"
APPTAINERPATH="/containers/apptainer/jellyfish:2.2.6--0"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

# Count k-mers (k=21) with canonical representation
apptainer exec --bind /data "$APPTAINERPATH" jellyfish count \
    -C -m 21 -s 5G -t "$SLURM_CPUS_PER_TASK" \
    -o "$OUTDIR/reads.jf" \
    <(zcat "$READFILE")

# Generate k-mer histogram
apptainer exec --bind /data "$APPTAINERPATH" jellyfish histo \
    -t "$SLURM_CPUS_PER_TASK" \
    "$OUTDIR/reads.jf" > "$OUTDIR/reads.histo"