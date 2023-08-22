configfile: "config.yaml"

rule all:
    input:
        "dc_workshop/data/SRR2584863_1_fastqc.html",
        "dc_workshop/data/SRR2584863_2_fastqc.html"




rule fastqc_R1_file:
    input:
        "{sample}_L001_R1_001.fastq.gz"
    output:
        "{sample}_L001_R1_001_fastqc.html" , 
        "{sample}_L001_R1_001_fastqc.zip"
        
    shell:
        """
        fastqc  {input} 
        """

rule fastqc_R2_file:
    input:
        "{sample}_L001_R2_001.fastq.gz"
    output:
        "{sample}_L001_R2_001_fastqc.html" , 
        "{sample}_L001_R2_001_fastqc.zip"
        
    shell:
        """
        fastqc  {input} 
        """      
        