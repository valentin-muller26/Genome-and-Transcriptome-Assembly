# Genome and Transcriptome Assembly

## Description and goal of the project


## 🛠️ Tools used
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
