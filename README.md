# Genome and Transcriptome Assembly

## Description and goal of the project

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
The read filtering was conducted using fastp version 0.24.1

More information about Fastp and the parameter can be found [here](https://github.com/OpenGene/fastp)

### 3. Quality control of the filtered reads `read 03_quality_control_post_filtering.sh`
The quality control of the filtered read was performed using FastQC version 0.12.1 with the same parameter as the one of the raw reads. This analysis was done to assess if the filtering was sufficient.

### 4. Kmer analysis `04_kmer_analysis.sh`
A kmer analysis was performed before the genome assembly using Jellyfish version 2.2.6 and [GenomeScope](http://genomescope.org/genomescope2.0/) . This analysis enabled to estimate genome size, error rate, heterozygosity and the percentage of repeat content. These genomic information are important to guide genome assembly parameters and strategies.

Jellyfish was employed to count the kmers and generate a histogram file compatible with GenomeScope visualization. The following command was used to generate a a binary .jf file contening the containing kmer counts using the following parameters :
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

### 5.2 HIFIASM genome assembly `05_assembly_hifiasm.sh`
The parameters for the genome assembly with HIFIASM 0.25.0 as the following :
```bash
  hifiasm \
    -o "$OUTDIR/HiFiasm_Lu1.asm" \
    -t "$SLURM_CPUS_PER_TASK" \
    "$READFILEFILTERED"
```
- -t : indicates  the number of threads used by flye
- -o: indicates the path for the output files

More information about Flye and more parameter can be found [here](https://github.com/chhylp123/hifiasm)

### 5.3 LJA genome assembly `05_assembly_LJA.sh`
The parameters for the genome assembly with LJA version 0.2 was the following :
```bash
  lja \
    -o "$OUTDIR" \
    -t "$SLURM_CPUS_PER_TASK" \
    --reads "$READFILEFILTERED"
```
- -t : indicates  the number of threads used by flye
- -o: indicates the path for the output files

More information about Flye and more parameter can be found [here](https://github.com/AntonBankevich/LJA/blob/main/docs/lja_manual.md)

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
- -o : path and name of the input for Read 1
- -O : path and name of the input for Read 2
- --thread : number of threads used by fastp
- --html : path and name for the  html report
- --json : path and name for the json report
  
More information about Fastp and the parameter can be found [here](https://github.com/OpenGene/fastp)
  
### 3. Quality control of the raw read `03_quality_control_post_filtering.sh`
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
    - 📁 04_kmer_analysis/ - K-mer analysis
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
