#!/bin/bash

ml samtools/1.15
output_file="/mnt/lustre/home/rjimenez/coverageXY.csv"
echo -e "#sample\tsupposed-sex\trname\tcoverage"
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

	# coverageX=$(samtools coverage -r X *sorted.dedup.bam 2>/dev/null| tail -n +2| awk '{print $1,$6}')
	# coverageY=$(samtools coverage -r Y *sorted.dedup.bam 2>/dev/null| tail -n +2| awk '{print $1,$6}')


	samtools coverage -r X *sorted.dedup.bam 2>/dev/null| tail -n +2|awk -v sample="$id" -v sex="$sex" -v coverageX="$coverageX" 'BEGIN { OFS="\t" } { 
        printf "%s\t%s\t%s\t%s\t%s\n", sample, sex,  $1, $6 }' 

	#salidaY=$(awk -v sample="$id" -v sex="$sex" -v coverageY="$coverageY" 'BEGIN { OFS="\t" } { 
     #   printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", sample, sex,  $coverageY }' )

	#echo salidaX
	#echo salidaY
	

	cd - > /dev/null

done
