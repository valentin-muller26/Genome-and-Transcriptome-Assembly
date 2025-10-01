#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Busco_flye
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/Busco_flye_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/Busco_flye_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/06_Busco_flye"
LOGDIR="$WORKDIR/log"
ASSEMBLYFILE="$WORKDIR/results/Pacbio/05_assembly_Flye/assembly.fasta"
APPTAINERPATH="/containers/apptainer/busco-v5.6.1_cv1.sif"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

module load BUSCO/5.4.2-foss-2021a

cd "$OUTDIR"
# Run Hifiasm assembly with PacBio HiFi reads
busco \
    --lineage brassicales_odb10 \
    -o "$OUTDIR" \
    -i "$ASSEMBLYFILE" \
    -c "$SLURM_CPUS_PER_TASK" \
    -m genome \
    -f