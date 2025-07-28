#!/usr/bin/env bash

# mkdir HLA 
cd HLA
# mkdir data
cd data

ml optitype
ml samtools/1.15


# sbatch --job-name='0583-047-ENOD_HLA' --cpus-per-task=8 --mem=256G ./HLA_analisis.sh 
# /mnt/lustre/scratch/CBRA/projects/ENOD/analysis/0583-047-ENOD/hs37d5/wgs/WDL-pipeline/raw_processed/0583-047-ENOD/0583-047-ENOD.R1.paired.trim.fq.gz 
# /mnt/lustre/scratch/CBRA/projects/ENOD/analysis/0583-047-ENOD/hs37d5/wgs/WDL-pipeline/raw_processed/0583-047-ENOD/0583-047-ENOD.R2.paired.trim.fq.gz 
# /mnt/lustre/scratch/CBRA/projects/ENOD/analysis/0583-047-ENOD/hs37d5/wgs/WDL-pipeline/alignment/0583-047-ENOD/0583-047-ENOD.sorted.dedup.bam
# Pasamos como parámetros los qc R1 y R2 resultantes del filtrado y el bam 


######## Obtención región HLA a partir de los fastQ #############################################################################

#path fastq R1 trim (Ej.:/mnt/lustre/scratch/CBRA/projects/ENOD/analysis/0447-049-ENOD/wgs/pipeline/v2.0/raw_processed/0470-110-ENOD/470-110-ENOD.R1.paired.trim.fq.gz)
pathR1=$1
#path fastq R2 trim  
pathR2=$2

razers3 -i 95 -m 1 -dr 0 -tc 16 -o sample_fished_1.bam /mnt/lustre/expanse/software/easybuild/x86_64/software/OptiType/1.3.5-foss-2021b-Python-3.9.6/data/hla_reference_dna.fasta $pathR1

razers3 -i 95 -m 1 -dr 0 -tc 16 -o sample_fished_2.bam /mnt/lustre/expanse/software/easybuild/x86_64/software/OptiType/1.3.5-foss-2021b-Python-3.9.6/data/hla_reference_dna.fasta $pathR2

samtools bam2fq sample_fished_1.bam > R1_fished.fastq
samtools bam2fq sample_fished_2.bam > R2_fished.fastq
rm sample_fished_1.bam
rm sample_fished_2.bam




######## Obtención región HLA a partir del BAM analisis 1º #######################################################################

# BAMfile from analisis(Ej.:/mnt/lustre/scratch/CBRA/projects/ENOD/analysis/0470-110-ENOD/wgs/pipeline/v2.0/alignment/0470-110-ENOD/0470-110-ENOD.sorted.dedup.bam)
bamfile=$3
id_muestra=$(basename $bamfile .sorted.dedup.bam)


chr_example=$(samtools view -H $bamfile | grep '@SQ' | head -n 1 | cut -f 2 | cut -d':' -f2)
echo $chr_example


samtools view --threads 16 -b -h $bamfile 6:28477797-33448354 > tmp.bamfile.mapped
samtools view --threads 16 -b -f 4 $bamfile 6:28477797-33448354 > tmp.bamfile.unmap
bamHLAfile=$(basename $bamfile .bam .wholeHLAregion.bam)
samtools merge -f --threads 16 $bamHLAfile tmp.bamfile.mapped tmp.bamfile.unmap
rm tmp.bamfile*
samtools index $bamHLAfile


samtools fastq --threads 16 -0 sample.other.fastq  -1 $id_muestra_R1_HLAregion.fastq -2 $id_muestra_R2_HLAregion.fastq  $id_muestra.sorted.dedup.wholeHLAregion.bam
rm sample.other.fastq




# Creación de directorios
cd ..
mkdir class1
mkdir class2
cd class1
mkdir polysolver
mkdir optitype 
pathClass1=$(pwd)
cd ../class2
pathClass2=$(pwd)

mkdir hla-hd
cd ../data
datadir=$(pwd)




########  class1  #############################################################################################################

# OPTITYPE
outdir=$pathClass1/optitype

python /mnt/lustre/expanse/software/easybuild/x86_64/software/OptiType/1.3.5-foss-2021b-Python-3.9.6/OptiTypePipeline.py \
-i R1_fished.fastq R2_fished.fastq --dna --verbose --outdir $outdir 



# POLYSOLVER
ml singularity
ml polysolver

outdir="$pathClass1/polysolver"
#Comprobar etnia en (info.txt)--> si no es caucasica cambiar input


singularity exec -C -B $datadir:/data -B $outdir:/tmp \
/mnt/lustre/expanse/software/easybuild/x86_64/software/polysolver/4.0/polysolver-singularity_v4.sif \
/home/polysolver/scripts/shell_call_hla_type /data/$id_muestra.sorted.dedup.wholeHLAregion.bam \
Caucasian 1 hg19 STDFQ 0 /tmp




########  Class2  #############################################################################################################
ml hlahd
which hlahd

# /mnt/lustre/expanse/software/easybuild/x86_64/software/hlahd/1.4.0-foss-2021b/bin/hlahd.sh
HLADIR=/mnt/lustre/expanse/software/easybuild/x86_64/software/hlahd/1.4.0-foss-2021b/


outdir="$pathClass2/hla-hd"

hlahd.sh -t 16 -m 70 -c 0.95 -f $HLADIR/freq_data/ ${id_muestra}_R1_HLAregion.fastq ${id_muestra}_R2_HLAregion.fastq   $HLADIR/HLA_gene.split.txt $HLADIR/dictionary/ $id_muestra $outdir



cd $pathClass2/hla-hd/$id_muestra/result 
cp *final.result.txt ../..
subdir=$(ls -d $pathClass1/optitype/*/)
cd $subdir
cp *result.tsv ..
