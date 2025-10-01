#!/usr/bin/env bash
#SBATCH --time=12:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=merqury
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/vmuller/assembly_annotation_course/log/merqury_%j.out
#SBATCH --error=/data/users/vmuller/assembly_annotation_course/log/merqury_%j.err

# -----------------------
# Paths
# -----------------------
WORKDIR="/data/users/${USER}/assembly_annotation_course"
READS="$WORKDIR/data/Lu-1/*.fastq.gz"   # PacBio HiFi reads - AJUSTEZ ce chemin
OUTDIR="$WORKDIR/results/Pacbio/08_Merqury"
LOGDIR="$WORKDIR/log"
mkdir -p "$OUTDIR"
mkdir -p "$LOGDIR"

# Assemblies
FLYE="$WORKDIR/results/Pacbio/05_assembly_Flye/assembly.fasta"
HIFIASM="$WORKDIR/results/Pacbio/05_assembly_Hifiasm/HiFiasm_Lu1_primary.fa"
LJA="$WORKDIR/results/Pacbio/05_assembly_LJA/assembly.fasta"

# Path inside container
export MERQURY="/usr/local/share/merqury"

# Container path
APPTAINERPATH="/containers/apptainer/merqury_1.3.sif"

# -----------------------
# Step 1: Build meryl DB from HiFi reads
# -----------------------
if [ ! -d "$OUTDIR/hifi.meryl" ]; then
  echo "Building meryl DB from reads..."
  apptainer exec --bind /data "$APPTAINERPATH" \
    meryl count k=21 output "$OUTDIR/hifi.meryl" $READS
else
  echo "Using existing meryl DB: $OUTDIR/hifi.meryl"
fi

# -----------------------
# Step 2: Run Merqury for each assembly
# -----------------------
for ASM in flye hifiasm lja; do
    echo "Running Merqury for $ASM..."
    mkdir -p "$OUTDIR/$ASM"
    cd "$OUTDIR/$ASM"
    
    if [ "$ASM" == "flye" ]; then
        ASMFILE="$FLYE"
    elif [ "$ASM" == "hifiasm" ]; then
        ASMFILE="$HIFIASM"
    elif [ "$ASM" == "lja" ]; then
        ASMFILE="$LJA"
    fi

    apptainer exec --bind /data "$APPTAINERPATH" \
      $MERQURY/merqury.sh "$OUTDIR/hifi.meryl" "$ASMFILE" "$ASM"
done

echo "Merqury analysis complete!"
echo "Results are in: $OUTDIR"