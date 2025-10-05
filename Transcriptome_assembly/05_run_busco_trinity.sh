#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Busco_trinity
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/Busco_trinity%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/Busco_trinity%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/RNASeq/05_Busco_trinity"
LOGDIR="$WORKDIR/log"
ASSEMBLYFILE="$WORKDIR/results/RNASeq/04_assembly_trinity/04_assembly_trinity.Trinity.fasta"
APPTAINERPATH="/containers/apptainer/busco-v5.6.1_cv1.sif"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

module load BUSCO/5.4.2-foss-2021a

cd "$OUTDIR"
# Buco for the trinity assembly
busco \
    --lineage brassicales_odb10 \
    -o "$OUTDIR" \
    -i "$ASSEMBLYFILE" \
    -c "$SLURM_CPUS_PER_TASK" \
    -m transcriptome \
    -f