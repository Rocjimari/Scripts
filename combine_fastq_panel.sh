#!/usr/bin/env bash

# Script para automatizar la combinación de archivos FASTQ R1 y R2 en los paneles de Vall d'Hebron.
# Para ejecutarlo, utiliza el siguiente comando:
# sbatch -J samples_ValldH -o job_samples_ValldH.out -e job_samples_ValldH.err -c 1 --mem 64G --wrap="./combine_fastq_panel.sh table_ids_nfiles.txt /mnt/lustre/scratch/CBRA/collaborations/Vall_dHebron/raw/RawData_PN46-52"
# 
# El primer argumento del script es un archivo de texto (.txt) que contiene dos columnas el listado de identificadores de muestras y el número de archivos correspondiente.
# Si este archivo no sigue la misma estructura modificar de la línea 15 a la 17
# El segundo argumento es la ruta al directorio donde se encuentran los archivos FASTQ correspondientes

start=$(date +%s)


archivo=$1
directorio=$2 # Directorio donde se encuentren archivos fastq

while IFS=$'\t' read -r id nfiles; do # Dividimos las columnas del archivo
    # Saltar la cabecera
    [[ "$id" == "sample_id" ]] && continue # Saltar primera linea (cabecero)

    
	mkdir -p "s${id}" # Creamos carpeta para cada muestra
	cd s"${id}"
	cp "${directorio}"/ID"${id}"* . # Copiamos archivos que comiencen por id de la muestra. Ej.:ID6124
	
    # Verificar cuántos archivos fueron copiados
    files_copiados=($(ls ID"${id}"*))
    num_archivos=${#files_copiados[@]}  # Número de archivos copiados

    # Si solo son 2 archivos no es necesario combinar R1 Y R2
    if [ "$num_archivos" -eq 2 ]; then
        
        # Renombrar los archivos copiados
        for file in "${files_copiados[@]}"; do
            if [[ "$file" =~ _1.fq.gz$ ]]; then
                mv "$file" "s${id}_R1.fastq.gz"
            elif [[ "$file" =~ _2.fq.gz$ ]]; then
                mv "$file" "s${id}_R2.fastq.gz"
            fi
        done

    # Si tiene más de 2 archivos significa que hay que combinar R1 Y R2
    else 		
		# Línea para generar archivo R1 y R2
		command1=$(cat <(find ID"${id}"*_1.fq.gz | sort | paste - - - -) | sort| gawk '{ print "cat",$1,$2,$3,$4,">", "s${id}_R1.fastq.gz";}')
		command2=$(cat <(find ID"${id}"*_2.fq.gz | sort | paste - - - -) | sort| gawk '{ print "cat",$1,$2,$3,$4,">", "s${id}_R2.fastq.gz";}') 	
			
		eval $command1
		eval $command2       	

		# ------------------R1-----------------------------------------------------------------------------------------------------------------
		# Comprobación de que la fusión ha ido bien, para R1:
		# cabeceros de lecturas de los archivos por separado
		for file in $(ls ID"${id}"*_1.fq.gz); do
			if [[ "$file" != "s${id}_R1.fastq.gz" ]]; then
			    zless "${file}" | grep -P '^@'
			fi
		done > cabeceros_R1


		# cabeceros de lecturas del archivo compendio generado
		zless "s${id}_R1.fastq.gz" | grep -P '^@' > cabeceros_L1L8_1
		# diferencia debe ser cero
		diff cabeceros_R1 cabeceros_L1L8_1
				



		#-------------------R2--------------------------------

		# Comprobación de que la fusión ha ido bien, para R2:
		# cabeceros de lecturas de los archivos por separado
		for file in $(ls ID"${id}"*_2.fq.gz); do
			if [[ "$file" != "s${id}_R2.fastq.gz" ]]; then
			    zless "${file}"| grep -P '^@'
			fi
		done > cabeceros_R2	

		# cabeceros de lecturas del archivo compendio generado
		zless "s${id}_R2.fastq.gz" | grep -P '^@' > cabeceros_L1L8_2
		# diferencia debe ser cero
		diff cabeceros_R2 cabeceros_L1L8_2
			


		# Comprobación de que las lecturas R1 y R2 están en el mismo orden en ambos archivos
		cat cabeceros_L1L8_1 | sed 's/ /\t/g' | cut -f 1 > ids_R1_L1L8
		cat cabeceros_L1L8_2 | sed 's/ /\t/g' | cut -f 1 > ids_R2_L1L8
		# diferencia debe ser cero
		if ! diff ids_R1_L1L8 ids_R2_L1L8 > /dev/null; then
			echo "R1 y R2 no tienen las mismas lecturas"
			# Si hay diferencias, ordena los archivos
			sort ids_R1_L1L8 -o ids_R1_L1L8
			sort ids_R2_L1L8 -o ids_R2_L1L8
		fi

					

		# Alguna estadística:
		nreads_sample23=`wc -l ids_R1_L1L8 | sed 's/ ids_R1_L1L8//g'`
		echo -e "El número de lecturas de la muestra s${id} r1 es ${nreads_sample23}."
		nreads_sample24=`wc -l ids_R2_L1L8 | sed 's/ ids_R2_L1L8//g'`
		echo -e "El número de lecturas de la muestra s${id} r2 es ${nreads_sample24}."


		##################################################################################################
		# Tareas finales
		##################################################################################################

		# Elimina archivos intermedios
		rm cabeceros* ids*

		
	fi
	cd ..
done < "$archivo"	

end=$(date +%s)
runtime=$((end-start))
echo "Tiempo total de ejecución: $runtime segundos"