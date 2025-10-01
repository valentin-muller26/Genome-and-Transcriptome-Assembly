# Genome and Transcriptome Assembly

## Description and goal of the project
This repository was created in the context of the course of genome and transcriptome assembly of the master of bioinformatics and computational biology. It contains two pipelines, one for the genome assembly and the other for transcriptome assembly. The goal of this project is to assemble the genome of the accession Lu-1 of *Arabidopsis thaliana* and a transcriptome assembly for the accession Sha. For that, we received PacBio HiFi reads for the genome assembly and Illumina reads for the transcriptome assembly.

## Genome assembly pipeline
### 1. Quality control of the raw read `01_quality_control.sh`
The raw read quality control was performed using FastQC version 0.12.1 with the following parameter 
```bash
fastqc -t $SLURM_CPUS_PER_TASK $PACBIO_FILE -o $OUTDIR
```
- -t : indicating the number of threads used
- -o : indicating the output directory

More information about FastQC and the parameter used can be found here

### 2. Read filtering `02_read_filtering.sh`
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

### 3. Quality control of the filtered reads `03_quality_control_post_filtering.sh`
The quality control of the filtered read was performed using FastQC version 0.12.1 with the same parameter as the one of the raw reads. This analysis was done to assess if the filtering was sufficient.

### 4. Kmer analysis `04_kmer_analysis.sh`
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

#### 5.1 Flye genome assembly `05_assembly_flye.sh`
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

#### 5.2 Hifiasm genome assembly `05_assembly_hifiasm.sh`
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

#### 5.3 LJA genome assembly `05_assembly_LJA.sh`
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
### 6. Busco assembly quality assessment
BUSCO (Benchmarking Universal Single-Copy Orthologs) version 5.4.2 was used to evaluate the biological completeness of each genome assembly by searching for highly conserved single-copy orthologs that should be present in the genome.

Three separate analyses were performed (`06_busco_flye.sh`, `06_busco_hifiasm.sh`, `06_busco_LJA.sh`), one for each assembler, using identical parameters:
```bash
busco \
    --lineage brassicales_odb10 \
    -o "$OUTDIR" \
    -i "$ASSEMBLYFILE" \
    -c "$SLURM_CPUS_PER_TASK" \
    -m genome \
    -f
```
- --lineage : Specifies the brassicales_odb10 dataset (4,596 BUSCO groups for Brassicales)
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

**Reference-free assessment (`07_quast_noref.sh`):**

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

**Reference-based assessment (07_quast_ref.sh)**
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

## 📁 Structure of the project
### **📁 assembly_annotation_course/**

- **📁 data/** - Raw input reads
  - **📁 Lu-1/** - Lu-1 reads (PacBio)
    - 📄 ERR11437310.fastq.gz - PacBio HiFi reads
  - **📁 RNAseq_Sha/** - RNAseq samples
    - 📄 ERR754081_1.fastq.gz - Illumina R1
    - 📄 ERR754081_2.fastq.gz - Illumina R2

- **📁 log/** - Log files

- **📁 results/** - Analysis results
  - **📁 Pacbio/** - Genomic assembly results for Lu-1
    - 📁 01_quality_control/ - Initial quality control
    - 📁 02_read_filtering/ - Read filtering
    - 📁 03_quality_control_post_filtering/ - Quality control of the filtered reads
    - 📁 04_kmer_analysis/ - Kmer analysis
    - 📁 05_assembly_Flye/ - Flye assembly
    - 📁 05_assembly_Hifiasm/ - Hifiasm assembly
    - 📁 05_assembly_LJA/ - LJA assembly
  - **📁 RNASeq/** - Transcriptomic assembly results
    - 📁 01_quality_control/ - Initial quality control
    - 📁 02_read_filtering/ - Read filtering
    - 📁 03_quality_control_post_filtering/ - Quality control of the filtered reads
    - 📁 04_assembly_trinity/ - Trinity assembly

- **📁 scripts/** - Analysis scripts
  - **📁 Pacbio/** - PacBio data scripts
    - 📄 01_quality_control.sh - Quality control of the raw PacBio HiFi reads
    - 📄 02_read_filtering.sh - Read filtering
    - 📄 03_post_correction.qcsh - Quality control of the filtered reads
    - 📄 04_kmer_analysis.sh - Kmer analysis
    - 📄 05_assembly_flye.sh - Flye assembly
    - 📄 05_assembly_hifiasm.sh - Hifiasm assembly
    - 📄 05_assembly_LJA.sh - LJA assembly
  - **📁 RNAseq/** - Transcriptome Assembly pipeline
    - 📄 01_quality_control.sh - Quality control of the raw Illumina reads
    - 📄 02_read_filtering.sh - Read filtering
    - 📄 03_post_correction.qcsh - Quality control of the filtered reads
    - 📄 04_assembly_trinity.sh - Trinity assembly
  - 📄 00_setup_environment.sh - Environment setup
  - 📄 README.md - Documentation of the project
 
## Author
Valentin Müller
