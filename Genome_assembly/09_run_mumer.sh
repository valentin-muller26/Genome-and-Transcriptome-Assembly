#!/usr/bin/env bash
#SBATCH --time=12:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=nucmer
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/nucmer_%j.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/nucmer_%j.err

# -----------------------
# Genome comparison using nucmer and mummerplot
# Compare Flye, Hifiasm, and LJA assemblies against the reference genome and each other
# -----------------------

# -----------------------
# Paths
# -----------------------
WORKDIR="/data/users/${USER}/assembly_annotation_course"
OUTDIR="$WORKDIR/results/Pacbio/09_Nucmer"
LOGDIR="$WORKDIR/log"
mkdir -p "$OUTDIR"
mkdir -p "$LOGDIR"

# Reference genome
REFERENCE="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"

# Assembly paths
FLYE="$WORKDIR/results/Pacbio/05_assembly_Flye/assembly.fasta"
HIFIASM="$WORKDIR/results/Pacbio/05_assembly_Hifiasm/HiFiasm_Lu1_primary.fa"
LJA="$WORKDIR/results/Pacbio/05_assembly_LJA/assembly.fasta"

# Container path
APPTAINERPATH="/containers/apptainer/mummer4_gnuplot.sif"

# -----------------------
# PART 1: Compare assemblies vs reference
# -----------------------
echo "=========================================="
echo "PART 1: Compare assemblies vs reference"
echo "=========================================="

# 1. Flye vs Reference
mkdir -p "$OUTDIR/flye_vs_ref"
cd "$OUTDIR/flye_vs_ref"

apptainer exec --bind /data "$APPTAINERPATH" nucmer \
    --prefix=flye_vs_ref \
    --breaklen=1000 \
    --mincluster=1000 \
    "$REFERENCE" \
    "$FLYE"

apptainer exec --bind /data "$APPTAINERPATH" mummerplot \
    -R "$REFERENCE" \
    -Q "$FLYE" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix=flye_vs_ref \
    flye_vs_ref.delta

# 2. Hifiasm vs Reference
mkdir -p "$OUTDIR/hifiasm_vs_ref"
cd "$OUTDIR/hifiasm_vs_ref"

apptainer exec --bind /data "$APPTAINERPATH" nucmer \
    --prefix=hifiasm_vs_ref \
    --breaklen=1000 \
    --mincluster=1000 \
    "$REFERENCE" \
    "$HIFIASM"

apptainer exec --bind /data "$APPTAINERPATH" mummerplot \
    -R "$REFERENCE" \
    -Q "$HIFIASM" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix=hifiasm_vs_ref \
    hifiasm_vs_ref.delta

# 3. LJA vs Reference
mkdir -p "$OUTDIR/lja_vs_ref"
cd "$OUTDIR/lja_vs_ref"

apptainer exec --bind /data "$APPTAINERPATH" nucmer \
    --prefix=lja_vs_ref \
    --breaklen=1000 \
    --mincluster=1000 \
    "$REFERENCE" \
    "$LJA"


apptainer exec --bind /data "$APPTAINERPATH" mummerplot \
    -R "$REFERENCE" \
    -Q "$LJA" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix=lja_vs_ref \
    lja_vs_ref.delta


# -----------------------
# PART 2: Compare assemblies against each other
# -----------------------
echo "=========================================="
echo "PART 2: Compare assemblies against each other"
echo "=========================================="

# 4. Flye vs Hifiasm
mkdir -p "$OUTDIR/flye_vs_hifiasm"
cd "$OUTDIR/flye_vs_hifiasm"

apptainer exec --bind /data "$APPTAINERPATH" nucmer \
    --prefix=flye_vs_hifiasm \
    --breaklen=1000 \
    --mincluster=1000 \
    "$FLYE" \
    "$HIFIASM"

apptainer exec --bind /data "$APPTAINERPATH" mummerplot \
    -R "$FLYE" \
    -Q "$HIFIASM" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix=flye_vs_hifiasm \
    flye_vs_hifiasm.delta

# 5. Flye vs LJA
mkdir -p "$OUTDIR/flye_vs_lja"
cd "$OUTDIR/flye_vs_lja"

apptainer exec --bind /data "$APPTAINERPATH" nucmer \
    --prefix=flye_vs_lja \
    --breaklen=1000 \
    --mincluster=1000 \
    "$FLYE" \
    "$LJA"

apptainer exec --bind /data "$APPTAINERPATH" mummerplot \
    -R "$FLYE" \
    -Q "$LJA" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix=flye_vs_lja \
    flye_vs_lja.delta

# 6. Hifiasm vs LJA
mkdir -p "$OUTDIR/hifiasm_vs_lja"
cd "$OUTDIR/hifiasm_vs_lja"

apptainer exec --bind /data "$APPTAINERPATH" nucmer \
    --prefix=hifiasm_vs_lja \
    --breaklen=1000 \
    --mincluster=1000 \
    "$HIFIASM" \
    "$LJA"

apptainer exec --bind /data "$APPTAINERPATH" mummerplot \
    -R "$HIFIASM" \
    -Q "$LJA" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix=hifiasm_vs_lja \
    hifiasm_vs_lja.delta

# -----------------------
# Summary
# -----------------------
echo "=========================================="
echo "Analysis complete!"
echo "[$(date +"%Y-%m-%d %H:%M:%S")]"
echo "Results are in: $OUTDIR/"
echo ""
echo "Generated comparisons:"
echo "  1. flye_vs_ref/"
echo "  2. hifiasm_vs_ref/"
echo "  3. lja_vs_ref/"
echo "  4. flye_vs_hifiasm/"
echo "  5. flye_vs_lja/"
echo "  6. hifiasm_vs_lja/"
echo ""
echo "Each directory contains:"
echo "  - *.delta (alignment coordinates)"
echo "  - *.png (dotplot visualization)"
echo "=========================================="