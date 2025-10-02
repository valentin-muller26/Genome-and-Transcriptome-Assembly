# Genome and Transcriptome Assembly

## Description and goal of the project
This repository was created in the context of the course of genome and transcriptome assembly of the master of bioinformatics and computational biology. It contains two pipelines, one for the genome assembly and the other for transcriptome assembly. The goal of this project is to assemble the genome of the accession Lu-1 of *Arabidopsis thaliana* and a transcriptome assembly for the accession Sha. For that, we received PacBio HiFi reads for the genome assembly and Illumina reads for the transcriptome assembly.

## Genome assembly pipeline
### 1. Quality control of the raw read `01_run_fastqc_raw_read.sh`
The raw read quality control was performed using FastQC version 0.12.1 with the following parameter 
```bash
fastqc -t $SLURM_CPUS_PER_TASK $PACBIO_FILE -o $OUTDIR
```
- -t : indicating the number of threads used
- -o : indicating the output directory

More information about FastQC and the parameter used can be found here

### 2. Read filtering `02_run_fastp.sh`
The read filtering for the genome was conducted using fastp version 0.24.1. Since we are working with PacBio HiFi reads, the parameter of fastp was set to perform no filtering :

```bash
fastp \
    -i "$READFILE" \
    -o "$OUTDIR/ERR11437310_filtered.fastq.gz" \
    -A -Q -L \
    -w "$SLURM_CPUS_PER_TASK" \
    -h "$OUTDIR/fastp_PacBio_Lu-1.html" \
    -j "$OUTDIR/fastp_PacBio_Lu-1.json"
```
- -i: path to the input raw read
- -o : path for the output
- -A: Disable adapter trimming (recommended for PacBio data)
- -Q: Disable quality filtering
- -L: Disable length filtering
- -w : number of threads used by fastp
- --html : path and name for the  html report
- --json : path and name for the json report

More information about Fastp and the parameter can be found [here](https://github.com/OpenGene/fastp)

### 3. Quality control of the filtered reads `03_run_fastqc_post_fastp.sh`
The quality control of the filtered read was performed using FastQC version 0.12.1 with the same parameter as the one of the raw reads. This analysis was done to assess if the filtering was sufficient.

### 4. Kmer analysis `04_run_jellyfish.sh`
A kmer analysis was performed before the genome assembly using Jellyfish version 2.2.6 and [GenomeScope](http://genomescope.org/genomescope2.0/) . This analysis enabled the estimation of genome size, error rate, heterozygosity and the percentage of repeat content. These genomic information are important to guide genome assembly parameters and strategies.

Jellyfish was employed to count the kmers and generate a histogram file compatible with GenomeScope visualization. The following command was used to generate a binary .jf file containing kmer counts using the following parameters :
```bash
  jellyfish count \
    -C -m 21 -s 5G -t "$SLURM_CPUS_PER_TASK" \
    -o "$OUTDIR/reads.jf" \
    <(zcat "$READFILE")
```
- -C : Specifies the usage of  canonical kmer (treats k-mers and their reverse complements as identical)
- -m : Sets the kmer size
- -s 5G : Allocates a 5GB
- -t : indicates  the number of threads
- <(zcat ...)  : Allows direct processing of compressed FASTQ files without prior decompression

The command `jellyfish histo` was used to convert the .jf file to an text-based histogram file containing k-mer frequency distributions, which can be directly imported into GenomeScope for genomic parameter estimation and visualization. 
```bash
jellyfish histo \
    -t "$SLURM_CPUS_PER_TASK" \
    "$OUTDIR/reads.jf" > "$OUTDIR/reads.histo"
```

### 5. Genome assembly
The assembly of the genome was performed with the three following software :

#### 5.1 Flye genome assembly `05a_run_assembly_flye.sh`
The parameters for the genome assembly with Flye version 2.9.5 was the following :
```bash
  flye \
    --pacbio-hifi "$READFILEFILTERED" \
    --threads "$SLURM_CPUS_PER_TASK" \
    --out-dir "$OUTDIR"
```
- --pacbio-hifi : indicates the path to the filtered PacBio HIFI reads
- --threads : indicates  the number of threads used by flye
-  --out-dir : indicates the path for the output files

More information about Flye and more parameter can be found [here](https://github.com/mikolmogorov/Flye/blob/flye/docs/USAGE.md)

#### 5.2 LJA genome assembly `05b_run_assembly_LJA.sh`
The parameters for the genome assembly with LJA version 0.2 was the following :
```bash
  lja \
    -o "$OUTDIR" \
    -t "$SLURM_CPUS_PER_TASK" \
    --reads "$READFILEFILTERED"
```
- -t : indicates  the number of threads used by LJA
- -o: indicates the path for the output files

More information about LJA and more parameter can be found [here](https://github.com/AntonBankevich/LJA/blob/main/docs/lja_manual.md)

#### 5.3 Hifiasm genome assembly `05c_run_assembly_hifiasm.sh`
The parameters for the genome assembly with HIFIASM 0.25.0 as the following :
```bash
  hifiasm \
    -o "$OUTDIR/HiFiasm_Lu1.asm" \
    -t "$SLURM_CPUS_PER_TASK" \
    "$READFILEFILTERED"
```
- -t : indicates  the number of threads used by Hifiasm
- -o: indicates the path for the output files
  
Hifiasm generates multiple output files in GFA (Graphical Fragment Assembly). To be able to assess the quality of the assembly, the primary assembly was converted from GFA to FASTA format using the following command:

```bash
awk '/^S/{print ">"$2;print $3}' "$OUTDIR/HiFiasm_Lu1.asm.bp.p_ctg.gfa" > "$OUTDIR/HiFiasm_Lu1_primary.fa"
```

More information about Hifiasm and more parameter can be found [here](https://github.com/chhylp123/hifiasm)


### 6. Busco assembly quality assessment
BUSCO version 5.4.2 was used to evaluate the biological completeness of each genome assembly by searching for highly conserved single-copy orthologs that should be present in the genome.

Three separate analyses were performed (`06a_run_busco_flye.sh`, `06b_run_busco_hifiasm.sh`, `06c_run_busco_LJA.sh`), one for each assembler, using identical parameters:
```bash
busco \
    --lineage brassicales_odb10 \
    -o "$OUTDIR" \
    -i "$ASSEMBLYFILE" \
    -c "$SLURM_CPUS_PER_TASK" \
    -m genome \
    -f
```
- --lineage : Specifies the brassicales_odb10 dataset
- -o : Output directory for results
- -i : Path to the assembly file
    - Flye: assembly.fasta
    - Hifiasm: HiFiasm_Lu1_primary.fa
    - LJA: assembly.fasta
- -c : Number of CPU threads
- -m genome : Activates genome assessment mode
- -f : Forces overwrite of existing results

### 7. QUAST - Comparative structural assessment
QUAST version 5.2.0 was used to evaluate and compare the quality the three genome assemblies. Two complementary analyses were performed: a reference-free assessment and a reference-based comparison against the *Arabidopsis thaliana* genome.

**Reference-free assessment (`07a_run_quast_analysis_noref.sh`):**

This analysis evaluates basic assembly metrics without relying on a reference genome:
```bash
quast.py \
    --eukaryote \
    --est-ref-size 135000000 \
    -o "$OUTDIR" \
    --threads "$SLURM_CPUS_PER_TASK" \
    --labels flye,hifiasm,lja \
    "$FLYE_ASSEMBLY_FILE" "$HIFIASM_ASSEMBLY_FILE" "$LJA_ASSEMBLY_FILE"
```
- --eukaryote : Enables eukaryote-specific metrics
- --est-ref-size : Specify the estimate reference genome size (135 Mbp based on k-mer analysis)
- --labels : Custom labels for each assembly (flye, hifiasm, lja)
- --threads : indicates the number of thread used by Quast

**Reference-based assessment (07b_run_quast_analysis_ref.sh)**
```bash
quast.py \
    --eukaryote \
    --est-ref-size 135000000 \
    -r "$REFERENCE" \
    --features "$ANNOTATION" \
    -o "$OUTDIR" \
    --threads "$SLURM_CPUS_PER_TASK" \
    --labels flye,hifiasm,lja \
    "$FLYE_ASSEMBLY_FILE" "$HIFIASM_ASSEMBLY_FILE" "$LJA_ASSEMBLY_FILE"
```
- -r : Specify the reference genome
- --features : Specify reference annotation for gene-level assessment

### 8. Assembly quality assesement Merqury  (`08_run_merqury.sh`)
Merqury version 1.3 was used to evaluate assembly quality by analyzing kmer of the assembly and the sequencing Pacbio HiFi reads. this analysis was done in two step :

**Step 1: Building meryl database**
First, a meryl k-mer database was generated from the PacBio HiFi reads:
```bash
meryl count k=21 output "$OUTDIR/hifi.meryl" $READS
```
- - k=21 : specifies the k-mer size
- output : indicates the path for the output meryl database

**Step 2: Running Merqury for each assembly**
```bash
$MERQURY/merqury.sh "$OUTDIR/hifi.meryl" "$ASMFILE" "$ASM"
```
- First argument : indicates the path to the meryl database generated in step 1
- Second argument : Path to the assembly file
- Third argument : Output prefix for the results (flye, hifiasm, or lja)

### 9. Comparative genomic using Nucmer and Mummerplot 
Nucmer from the MUMmer was used to perform whole-genome alignments. Two types of comparisons were conducted: assemblies against the reference genome and assemblies against each other. Mummerplot was used to generate dotplot visualizations of the alignments.

**Assembly vs Reference comparisons**
Each assembly was aligned against the Arabidopsis thaliana reference genome using nucmer with the following parameters:
```bash
nucmer \
    --prefix=flye_vs_ref \
    --breaklen=1000 \
    --mincluster=1000 \
    "$REFERENCE" \
    "$ASSEMBLY"
```
- --prefix : indicates the output prefix for the alignment files
- --breaklen : indicates the minimum length of a maximal exact match (1000 bp)
- --mincluster : indicates the minimum cluster length (1000 bp)

The alignments were then visualized using mummerplot with the following parameters:
```bash
mummerplot \
    -R "$REFERENCE" \
    -Q "$ASSEMBLY" \
    --filter \
    -t png \
    --large \
    --layout \
    --fat \
    --prefix=flye_vs_ref \
    flye_vs_ref.delta
```
- -R : indicates the reference genome
- -Q : indicates the query assembly
- --filter : displays only the best mapping for each position
- -t png : indicates the output format (PNG)
- --large : optimizes visualization for large genomes
- --layout : creates a layout file
- --fat : uses thicker lines for visibility

**Assembly vs Assembly comparisons**
Pairwise comparisons were performed between the three assemblies (Flye vs Hifiasm, Flye vs LJA, Hifiasm vs LJA) using the same nucmer and mummerplot parameters as described above.

## Transcriptome assembly pipeline
### 1. Raw reads quality control `01_quality_control.sh`
The raw read quality control was performed using FastQC version 0.12.1 with the following parameter 
```bash
fastqc -t $SLURM_CPUS_PER_TASK $PACBIO_FILE -o $OUTDIR
```
- -t : indicating the number of threads used
- -o : indicating the output directory
  
More information about FastQC and the parameter used can be found here


### 2. Read filtering `02_read_filtering.sh`
The read filtering was conducted using fastp version 0.24.1
```bash
 fastp \
  -i $RNAFILE_READ1 \                             
  -I $RNAFILE_READ2 \                      
  -o $OUTDIR/ERR754081_1.trimmed.fastq.gz \
  -O $OUTDIR/ERR754081_2.trimmed.fastq.gz \
  --thread $SLURM_CPUS_PER_TASK \
  --html $OUTDIR/fastp_RNASeq.html \
  --json $OUTDIR/fastp_RNASeq.json
```
- -i: path to the input Read 1
- -I : path to the input Read 2
- -o : path and name of the output for Read 1
- -O : path and name of the output for Read 2
- --thread : number of threads used by fastp
- --html : path and name for the  html report
- --json : path and name for the json report
  
More information about Fastp and the parameter can be found [here](https://github.com/OpenGene/fastp)
  
### 3. Quality control of the filtered reads `03_quality_control_post_filtering.sh`
The quality control of the filtered read was performed using FastQC version 0.12.1 with the same parameter as the one of the raw reads. This analysis was done to assess if the filtering was sufficient.

### 4. Assembly of the transcriptome 
The assembly of the transcriptome was done using Trinity version 2.15.1 using the following parameters
```bash
Trinity \
    --seqType fq \
    --left "$RNAFILE_READ1_FILTERED" \
    --right "$RNAFILE_READ2_FILTERED" \
    --CPU "$SLURM_CPUS_PER_TASK" \
    --max_memory "64G" \
    --output "$OUTDIR" \
```
- --seqType : indicates the type of input reads fq is for fastq files
- --left : indicates the path to the Read 1
- --right : indicates the path to the Read 2
- --CPU : indicates the number of CPUs to use
- --max_memory : indicates the maximum RAM used 
- --output : indicates the path of the output directory

More information about Trinity and the parameter can be found [here](https://github.com/trinityrnaseq/trinityrnaseq/wiki)

### 5. Busco transcriptome quality assessment `05_run_busco_trinity.sh`
BUSCO version 5.4.2 was used to evaluate the quality of the assembly of the transcriptome created by Trinity using the following parameters :
```bash
busco \
    --lineage brassicales_odb10 \
    -o "$OUTDIR" \
    -i "$ASSEMBLYFILE" \
    -c "$SLURM_CPUS_PER_TASK" \
    -m transcriptome \
    -f
```
- --lineage : indicates the brassicales_odb10 dataset
- -o : indicates the output directory for results
- -i : indicates the path to the Trinity assembly file
- -c : indicates the number of CPU threads
- -m transcriptome : indicates the transcriptome assessment mode
- -f : forces overwrite of existing results
  
## 🛠️ List of the tools used
| Tool | Version |
|------|---------|
| FastQC | 0.12.1 |
| fastp | 0.24.1 |
| Jellyfish | 2.2.6 | 
| Flye | 2.9.5 |
| Hifiasm | 0.25.0 |
| LJA | 0.2 |
| Trinity | 2.15.1 |
| BUSCO | 5.4.2 |
| QUAST | 5.2.0 |
| Merqury | 1.3 |
| MUMmer | 4 |


## Author
Valentin Müller
