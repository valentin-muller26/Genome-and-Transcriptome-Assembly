#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Quast
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/Quast%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/Quast%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/07_Quast_noref"
LOGDIR="$WORKDIR/log"
APPTAINERPATH="/containers/apptainer/quast_5.2.0.sif"



#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

cd "$OUTDIR"
# Run Quast without reference
apptainer exec --bind /data "$APPTAINERPATH" quast.py \
    --eukaryote --est-ref-size 135000000 \
    -o "$OUTDIR" \
    --threads "$SLURM_CPUS_PER_TASK" \
    --labels flye,hifiasm,lja \
    $FLYE $HIFIASM $LJA