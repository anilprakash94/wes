# wes

##Codes for Whole Exome Sequence analysis

* Converts fastq files to SAM alignment file
    bwa mem -M -R '@RG\tID:sample_1\tLB:sample_1\tPL:ILLUMINA\tpm:HISEQ\tSM:sample_1' hg19idx input_R1.fq.gz input_R2.fq.gz > input_aligned_reads.sam

*Runs all the commands like from SAM format comversion to recalibration
    bash align_to_recal.sh

*The recalibrated BAM file can be used for various downstream analysis

*For denovo variant calling:

    samtools mpileup -B -q 1 -f hg19.fasta father_recal_reads.bam mother_recal_reads.bam child_recal_reads.bam > child.mpileup

    java -jar /VarScan.v2.3.9.jar trio child.mpileup child.mpileup.output --min-coverage 10 --min-var-freq 0.20 --p-value 0.05 -adj-var-freq 0.05 -adj-p-value 0.15
