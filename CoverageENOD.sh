#!/bin/bash

ml samtools/1.15

echo -e "#sample\tsupposed-sex\tmeandepth">> ENOD_wes.txt
file="$1"


while read -r sample_id sex bam_file_path; do

    sample_id=$(echo "$sample_id" | xargs)
    sex=$(echo "$sex" | xargs)
    bam_file=$(echo "$bam_file_path" | xargs)
    coverage=$(samtools coverage --region Y:2654896-2655723 "$bam_file" 2>/dev/null | tail -n +2|cut  -f7)
    echo -e "$sample_id\t$sex\t$coverage">> ENOD_wes.txt
        
     
done < "$file"