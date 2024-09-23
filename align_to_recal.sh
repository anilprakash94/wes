#!/bin/bash

name=$(ls | grep "aligned_reads.sam")

for sample in `echo "$name" | cut -c 1-13`; do  

samtools view -bS $sample"_aligned_reads.sam" > $sample"_aligned_reads.bam"

samtools sort $sample"_aligned_reads.bam" -o $sample"_sorted_reads.bam"

samtools index $sample"_sorted_reads.bam" 

samtools faidx hg19.fasta

gatk CreateSequenceDictionary -R hg19.fasta.gz

gatk MarkDuplicates -I $sample"_sorted_reads.bam" --REMOVE_DUPLICATES -O $sample"_dedup_reads.bam" -M $sample"_metrics.txt"

samtools index $sample"_dedup_reads.bam"

gatk HaplotypeCaller -R hg19.fasta -L Exome-Agilent_V6.bed -I $sample"_dedup_reads.bam" -O $sample"_raw_variants.vcf"

gatk SelectVariants -R hg19.fasta -L Exome-Agilent_V6.bed -V $sample"_raw_variants.vcf"  -select-type SNP -O $sample"_raw_snps.vcf"

gatk SelectVariants -R hg19.fasta -L Exome-Agilent_V6.bed -V $sample"_raw_variants.vcf" -select-type INDEL -O $sample"_raw_indels.vcf"

gatk VariantFiltration -R hg19.fasta -L Exome-Agilent_V6.bed -V  $sample"_raw_snps.vcf" -filter "QD < 2.0 || FS> 30.0 || MQ < 40.0 || MQRankSum < -3.0 || ReadPosRankSum < -3.0 || SOR > 3.0" --filter-name “basic_snp_filter” -O $sample"pre_filtered_snps.vcf" 

gatk VariantFiltration -R hg19.fasta -L Exome-Agilent_V6.bed -V $sample"_raw_indels.vcf" -filter "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0" --filter-name “basic_indel_filter” -O $sample"pre_filtered_indels.vcf"

gatk SelectVariants -R hg19.fasta -L Exome-Agilent_V6.bed -V $sample"pre_filtered_snps.vcf"  -select-type SNP --exclude-filtered -O $sample"_filtered_snps.vcf"

gatk SelectVariants -R hg19.fasta -L Exome-Agilent_V6.bed -V $sample"pre_filtered_indels.vcf" -select-type INDEL --exclude-filtered -O $sample"_filtered_indels.vcf"

gatk BaseRecalibrator -R hg19.fasta -L Exome-Agilent_V6.bed -I $sample"_dedup_reads.bam" --known-sites $sample"_filtered_snps.vcf" --known-sites $sample"_filtered_indels.vcf" -O $sample"_recal_data.table"

gatk ApplyBQSR -L Exome-Agilent_V6.bed -I $sample"_dedup_reads.bam" -bqsr $sample"_recal_data.table" -O $sample"_recal_reads.bam"

done
