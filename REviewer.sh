#!/bin/bash

sampleID="$1"

loci="ABCD3,AFF2,AR,ARX_1,ARX_2,ATXN10,ATXN8OS,ATN1,ATXN1,ATXN2,ATXN3,ATXN7,BEAN1,C9ORF72,CACNA1A,CBL,CNBP,COMP,CSTB,DAB1,DIP2B,DMD,DMPK,EIF4A3,FGF14,FMR1,FOXL2,FXN,GIPC1,GLS,HOXA13_1,HOXA13_2,HOXA13_3,HOXD13,HTT,JPH3,LRP12,MARCHF6,NIPA1,NOTCH2NLC,NOP56,NUTM2B-AS1,PABPN1,PHOX2B,PPP2R2B,PRNP,PRDM12,RAPGEF2,RFC1-AAGGG,RFC1-ACAGG,RILPL1,RUNX2,SAMD12,SOX3,STARD7,TBP,TBX1,TCF4,THAP11,TNRC6A,VWA1,XYLT1,YEATS2,ZFHX3,ZIC2,ZIC3"


# Convertir a lista con espacios
loci_list=$(echo "$loci" | tr ',' ' ')

# Ruta al reference
reference="/mnt/lustre/scratch/CBRA/data/indexed_genomes/bwa/hs37d5/hs37d5.fa"

# Ruta al catálogo
catalog="/mnt/lustre/home/rjimenez/Pruebas_pipeline/variant_catalog.json"

# Recorrer cada locus
for i in $loci_list; do
    echo "Procesando locus: $i"

    # Entrar a la carpeta del locus si existe
    if [ -d "$i" ]; then
        cd "$i"

        samtools index "${i}_realigned-sorted.bam"
        

        # Ejecutar REviewer
        REviewer \
            --reads "${i}_realigned-sorted.bam" \
            --vcf "${i}.vcf" \
            --catalog "$catalog" \
            --locus "$i" \
            --reference "$reference" \
            --output "${sampleID}_${i}_result"

        if [ "${i}" == "XYLT1" ]; then

             REviewer \
            --reads "${i}_realigned-sorted.bam" \
            --vcf "${i}.vcf" \
            --catalog "/mnt/lustre/home/rjimenez/pipelines/stripy-pipeline/reference/XYLT1/variant_catalog_extended.json" \
            --locus "$i" \
            --reference "/mnt/lustre/home/rjimenez/pipelines/stripy-pipeline/reference/XYLT1/xylt1_ref.fa" \
            --output "${sampleID}_${i}_result"
        fi

        rm *.bam*
        rm *vcf

        cd ..
    else
        echo "⚠️ Carpeta '$i' no encontrada, saltando..."
    fi
done
