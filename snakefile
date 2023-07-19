configfile: "config.yaml"

rule fastqc:
    input:
        R1_input="directory/{sample}_L001_R1_001.fastq.gz",
        R2_input="directory/{sample}_L001_R2_001.fastq.gz"
    output: 
        R1_output="directory/{sample}_L001_R1_001_fastqc.html" , "directory/{sample}_L001_R1_001_fastqc.zip"
        R2_output="directory/{sample}_L001_R2_001_fastqc.html" , "directory/{sample}_L001_R2_001_fastqc.zip"
    params:
          dir="directory"
    shell:
        """
        fastqc  {input.R1_input} -o {params.dir} &&
        fastqc  {input.R2_input} -o {params.dir}
        """


           
        