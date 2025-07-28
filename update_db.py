#!/usr/bin/env python3
# coding: utf-8

# Para ejecutar este script debe colocarse dentro de la carpeta directorio que contiene las carpetas de las bases de datos que se quiere ejecutar
# Abre una terminal 
# Utiliza el comando cd para navegar hasta el directorio que contiene los directorio de las bases de datos que se quieren actualizar. 
# Una vez dentro de la carpeta ejecutar script


from datetime import date
from funciones.funciones import *
import argparse

parser = argparse.ArgumentParser(description='Update databases')
parser.add_argument('-l', '--db', nargs='+', type=str, help='List of databases to be updated: resfinder_db, pointfinder_db, disinfinder_db, plasmidfinder_db,serotypefinder_db, virulencefinder_db, mlst_db, abricate_db o lmon')
parser.add_argument('-d', '--abricate_db', nargs='+', type=str, help='List of databases to be updated in abricate_db: megares, argannot, card, ecoh o vfdb')
parser.add_argument('-p', '--path',  help='Path to the root folder where the databases are located')

args = parser.parse_args()



if args.db:
    updated_repositories = []
    error_repositories = []
    for e in args.db:
        try:
            if e == "mlst_db":
                updatemlst_db(e,args.path)
                updated_repositories.append(e)
            elif e == "abricate_db":
                for d in args.abricate_db:
                    updateAbricate_db(d, e,args.path)
                    updated_repositories.append(d)
            elif e == "lmon":
                update_cgMLST1748(args.path)
                updated_repositories.append(e)
            else: #para las demas bases de datos: resfinder_db, pointfinder_db, disinfinder_db, plasmidfinder_db,serotypefinder_db y virulencefinder_db
                update_db(e,args.path)                
                updated_repositories.append(e)
                
        except Exception as ex:
            error_repositories.append((e, str(ex)))

    if error_repositories:
        for repo, error_msg in error_repositories:
            print(f"Error al actualizar la base de datos {repo}: {error_msg}")
else:
    print("No databases selected.")
    
archivo_tsv_salida = "versiones.tsv"
original_dir = args.path
archivos_version = buscar_archivos_version(original_dir)
crear_archivo_tsv(archivos_version, archivo_tsv_salida)  
print("Las bases de datos actualizadas son:")
for repo in updated_repositories:
    print(repo)

