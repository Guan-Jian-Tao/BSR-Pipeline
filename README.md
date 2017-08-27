# BSR Pipeline
The purpose of the script is to call snp from Multiple RNA-seq data except raw data cleaning and SNP filtering. 
>perl RNA.SNP.BSR.Pipeline.pl -h
>Usage:

>Run by typing: 

>perl RNA.SNP.BSR.Pipeline.pl -exprfile \[Experiment file\] -logfile \[main log file (.txt)\] -bam_num \[bam files 
number\] -chrlen \[chromosome length file\] -start_code \[Start Code\]

    Required params:
        -e|exprfile                                                     [s]     Experiment file
        -l|logfile                                                      [s]     Main Log file (.txt)
        -n|bam_num                                                      [i]     Bam files number
        -c|chrlen                                                       [s]     Chromosome length file (.txt)
        -p|picard                                                       [s]     Picard PATH
        -g|GATK                                                         [s]     GATK PATH
        -s|start_code                                           [i]     Start Code (1-ordinates)
        start code:
                1                       S1_STAR;
                2                       S2_Index;
                3                       S3_Mark_Duplicates;
                4                       S4_SplitN;
                5                       S5_TargetCreator;
                6                       S6_Realigner;
                7                       S7_HaplotypeCaller;
                8                       S6_Depth;
    Example: perl RNA.SNP.BSR.Pipeline.pl -exprfile ExperimentalDesign.txt -logfile /wanglab2/guanjt/potBAC/Analysis1.dir/Log.dir/Main.Log.txt -bam_num 8 -chrlen Chr.length.txt -start_code 1

The start code is used to restart the pipeline from a specific step in order to save your life.

We can set the read depth threshold according to the results of code 8.   

Chr.length.txt is a text form where the chromosome length is written. 