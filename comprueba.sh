#!/usr/bin/env bash

# Ejecutar en carpeta analysis

# samples needs to be a text file named <batch>.txt, for example PN27.txt
samples=$1
# remove .txt from batch name
batch=${samples/.txt}
echo $batch
for sample in $(cat $samples) # | tail -n+6)
do
  v=$(echo $sample | cut -f1 -d'|')
  sex=$(echo $sample | cut -f2 -d'|')
  echo sample: $v, sex:$sex


  # Path
  variation_dir="../analysis/$v/panel/WDL-pipeline/variation"
  echo $variation_dir
  raw_dir="$v/panel_neumv4_hg38"
  slurm_file="$raw_dir/slurm.out"
  vcf_file="$variation_dir/labeled.vcf.gz"
  echo $vcf_file
  # Iniacializamos las variables

  succeed_status="NO"
  vcf_size="N/A"

  # Comprobaciones
  # Comprobar labeled.vcf.gz tenga tamaño 
  # carpeta analysis/$v/panel/WDL-pipeline/variation
  if ls $vcf_file 1> /dev/null 2>&1; then  # Si existe el archivo vcf
    vcf_size=$(stat -c%s "$vcf_file") # Obtenemos el tamaño del archivo
  else
    vcf_file=0
  fi


  # Comprobar slurm.out "succeed"
  # carpeta raw/$v/panel_neumv4_hg38
  if [[ -f "$slurm_file" ]]; then
    if grep -q "'Succeeded'" "$slurm_file"; then # Si ha salido todo bien aparece "'Succeeded'" en el archivo
      succeed_status="YES"
    fi
  else
    succeed_status="NO"
  fi


  # crear tabla con $id | Boolean succeed | tmño .vcf

  # Agregar resultados a la tabla
  printf "%-15s %-10s %-20s\n" "$v" "$succeed_status" "$vcf_size" "$variation_dir" "$vcf_file" >> "$output_table"
done



