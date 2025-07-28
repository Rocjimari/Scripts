#!/bin/bash

ml samtools/1.15
output_file="/mnt/lustre/home/rjimenez/coverageXY.csv"
echo -e "#sample\tsupposed-sex\trname\tstartpos\tendpos\tnumreads\tcovbases\tcoverage\tmeandepth\tmeanbaseq\tmeanmapq"
file="$1"

muestras=$(find . -type d -name "alignment")
for i in $muestras;do 
	
	if [[ "$i" != *"/wgs/"* ]]; then
        continue  
    fi

    if [[ "$i" == *"/hg38/"* ]]; then
        continue  
    fi


	id=$(echo "$i" | sed 's|^\./||' | cut -d'/' -f1)

	sex=$(awk -F',' -v sample="$id" '$1 == sample { print $2; exit }' "$file")

	cd ${i}/${id}  2>/dev/null || continue

    salida=$(samtools coverage --region Y:2654896-2655723 *.sorted.dedup.bam 2>/dev/null | tail -n +2 | 
    awk -v sample="$id" -v sex="$sex" 'BEGIN { OFS="\t" } { 
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", sample, sex, $1, $2, $3, $4, $5, $6, $7, $8, $9
    }' | grep -P "\tXY\t")


	echo -e "$salida" >> "$output_file"

	cd - > /dev/null
done

