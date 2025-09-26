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

More information about Fastp and the parameter used can be found here

### 2. Read filtering `02_read_filtering.sh`
The read filtering was conducted using fastp version 0.24.1

More information about FastQC and the parameter can be found here

### 3. Quality control of the filtered reads `read 03_quality_control_post_filtering.sh`
The quality control of the filtered read was performed using FastQC version 0.12.1 with the same parameter as the one of the raw reads. This analysis was done to assess if the filtering was sufficient.



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
  
### 3. Quality control of the raw read `03_quality_control_post_filtering.sh`
The quality control of the filtered read was performed using FastQC version 0.12.1 with the same parameter as the one of the raw reads. This analysis was done to assess if the filtering was sufficient.

### 4. Assembly of the transcriptome 
The assembly of the transcriptome was done using Trinity version 2.15.1 

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
    - 📄 04_kmer_analysis.sh - K-mer analysis
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
