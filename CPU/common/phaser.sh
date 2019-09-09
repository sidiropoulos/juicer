#!/bin/bash

export mnd=/mnt/qnap/work/nikos/rpe/RPE_merged/mnd/merged_nodups.txt
export vcf=/mnt/qnap/work/nikos/rpe/RPE_merged/snp/RPE.hic.filtered.recode.vcf
export juiceDir=/home/nikos/software/juicer/CPU
export sample=RPE
out_dir=/mnt/qnap/work/nikos/rpe/RPE_merged/phaser_benchmark/denovo

cd $out_dir

prep_parser_inputs() {
  sed 's/chr//g' ${sample}_heterozygous_positions.txt  | \
  grep -w "^$1" | sed 's/\t/ /g' > ${sample}_${1}_heterozygous_positions.txt

  sed 's/chr//g' ${sample}_chr_pos.txt  | \
  grep -w "^$1"  > ${sample}_${1}_chr_pos.txt

}

export -f prep_parser_inputs

parallel --will-cite -j 23 prep_parser_inputs {} ::: {1..22} X

annotate_mnd () {
  awk -v chr=$1 '$2==chr && $6==chr && $9 >= 10 && $12 >= 10' $mnd | ${juiceDir}/common/diploid.pl -s ${sample}_${1}_chr_pos.txt -o ${sample}_${1}_heterozygous_positions.txt > ${sample}_snp_annotated_${1}.txt
}

export -f annotate_mnd

parallel --will-cite -j 23 annotate_mnd {} ::: {1..22} X


snp_stats() {
 ${juiceDir}/common/snp_stats.awk ${sample}_snp_annotated_${1}.txt > snp_stats_${1}.txt 2> snps_found_${1}.txt

  wc -l ${sample}_${1}_heterozygous_positions.txt | \
    awk 'OFS="\t" {print "Total unique SNPs", $1}' >> snp_stats_${1}.txt
  sort snps_found_${1}.txt | uniq| wc -l | \
    awk 'OFS="\t" {print "Total unique SNPs on informative read-pairs", $0}' >> snp_stats_${1}.txt

  rm snps_found_${1}.txt
}

export -f snp_stats

parallel --will-cite -j 23 snp_stats {} ::: {1..22} X

echo -e "chr\ttotal\ttotal_single\tsingle_mismatch\ttotal_both\tcis_short\tcis_long\tboth_mismatch\tref\talt\tsnps_total\tsnps_present\tsnps_ratio" > snp_stats.txt

for i in {1..22} X;
do
  cut -f 2 snp_stats_${i}.txt | awk '{print}' ORS="\t" | awk -v chr=$i '{print chr, $0, $11/$10}' >> snp_stats.txt
  rm snp_stats_${i}.txt
done
