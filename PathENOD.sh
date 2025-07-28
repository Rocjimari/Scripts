#!/bin/bash


muestras=$(find . -type f -name "*.sorted.dedup.bam" | grep "alignment"| grep "hs37d5"| grep "wgs")

for i in $muestras;do 
	

	# id=$(echo "$i" | sed 's|^\./||' | cut -d'/' -f1)

	echo ${i}

    
done
