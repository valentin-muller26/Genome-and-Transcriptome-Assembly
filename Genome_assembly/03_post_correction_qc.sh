#!/usr/bin/env bash
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=FastQC_Pacbio_Filtered
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/FastQC_Pacbio_Filtered_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/FastQC_Pacbio_Filtered_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/03_quality_control_post_filtering"
LOGDIR="$WORKDIR/log"
READFILEFILTERED="$WORKDIR/results/Pacbio/02_read_filtering/ERR11437310_filtered.fastq.gz"
APPTAINERPATH="/containers/apptainer/fastqc-0.12.1.sif"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

#run fastqc with the number of thread indicated for SLURM for the filtered reads and put the result in the outdir
apptainer exec --bind /data "$APPTAINERPATH" fastqc -t "$SLURM_CPUS_PER_TASK" "$READFILEFILTERED" -o "$OUTDIR"