#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Assembly_Hifiasm
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/Assembly_Hifiasm_%J.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/Assembly_Hifiasm_%J.err
#SBATCH --partition=pibu_el8

#Setting the constant for the directories and required files
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/05_assembly_Hifiasm"
LOGDIR="$WORKDIR/log"
READFILEFILTERED="$WORKDIR/results/Pacbio/02_read_filtering/ERR11437310_filtered.fastq.gz"
APPTAINERPATH="/containers/apptainer/hifiasm_0.25.0.sif"

#Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

#Create the directory output if not present
mkdir -p "$OUTDIR"

# Run Hifiasm assembly with PacBio HiFi reads
apptainer exec --bind /data "$APPTAINERPATH" hifiasm \
    -o "$OUTDIR/HiFiasm_Lu1.asm" \
    -t "$SLURM_CPUS_PER_TASK" \
    "$READFILEFILTERED"


# Convert primary assembly (GFA to FASTA)
awk '/^S/{print ">"$2;print $3}' "$OUTDIR/HiFiasm_Lu1.asm.bp.p_ctg.gfa" > "$OUTDIR/HiFiasm_Lu1_primary.fa"

# Convert alternate assembly (GFA to FASTA) 
awk '/^S/{print ">"$2;print $3}' "$OUTDIR/HiFiasm_Lu1.asm.bp.a_ctg.gfa" > "$OUTDIR/HiFiasm_Lu1_alternate.fa"