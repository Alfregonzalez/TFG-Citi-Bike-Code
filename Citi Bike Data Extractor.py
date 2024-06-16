#!/usr/bin/env python
# coding: utf-8

# In[1]:


import requests
from bs4 import BeautifulSoup

url = 'https://s3.amazonaws.com/tripdata/'

# load url content into soup
r = requests.get(url)
soup = BeautifulSoup(r.text, 'xml')

# extract file names from soup
files = soup.find_all('Key')
clean_files = []
for i in range(len(files)-1):
    clean_files.append(files[i].get_text())
    
clean_files


# In[2]:


filter_files = []

data19 = '2019-citibike-tripdata.zip'
data20 = "2020-citibike-tripdata.zip"
data22 = "2022-citibike-tripdata.zip"


filter_files.append(data19)
filter_files.append(data20)
filter_files.append(data22)


# In[3]:


# Descargamos en una carpeta local todos los archivos que hemos filtrado
import os

output_folder = r'C:\Users\alfre\OneDrive\Documentos\5º Carrera\TFG\TFG Business Analytics\Zips'

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

for file in filter_files:
    file_name = file
    file_url = url + file_name
    file_path = os.path.join(output_folder, file_name)
    
    # Descargar el archivo
    with open(file_path, 'wb') as f:
        response = requests.get(file_url)
        f.write(response.content)
        


# In[5]:


import shutil
import zipfile

input_folder = r'C:\Users\alfre\OneDrive\Documentos\5º Carrera\TFG\TFG Business Analytics\Zips'
output_folder = r'C:\Users\alfre\OneDrive\Documentos\5º Carrera\TFG\TFG Business Analytics\Descompresion'

# Asegúrate de que la carpeta de destino exista
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

# Lista los archivos ZIP en la carpeta de descarga
zip_files = [f for f in os.listdir(input_folder) if f.endswith('.zip')]

for zip_file in zip_files:
    zip_file_path = os.path.join(input_folder, zip_file)
    
    # Abre el archivo ZIP
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        # Extrae todos los archivos en la carpeta de destino
        zip_ref.extractall(output_folder)
        
# Removemos la carpeta que se ha creado en nuestro directorio para los usuarios de mac


delete_folder = r'C:\Users\alfre\OneDrive\Documentos\5º Carrera\TFG\TFG Business Analytics\Descompresion\__MACOSX'

# Verifica si la carpeta existe antes de intentar eliminarla
if os.path.exists(delete_folder):
    shutil.rmtree(delete_folder)



# In[8]:


import os
import shutil

# Función para extraer archivos de cada carpeta y eliminar las carpetas vacías
def extraer_y_eliminar_carpeta_vacia(ruta):
    # Recorre todas las carpetas en la ruta especificada
    for carpeta_actual, subcarpetas, archivos in os.walk(ruta):
        # Extraer archivos de la carpeta actual
        for archivo in archivos:
            # Ruta completa del archivo
            ruta_archivo = os.path.join(carpeta_actual, archivo)
            # Mueve el archivo fuera de la carpeta actual
            ruta_destino = os.path.join(ruta, archivo)
            if os.path.exists(ruta_destino):
                os.remove(ruta_destino)
            shutil.move(ruta_archivo, ruta_destino)
        
        # Eliminar las carpetas vacías después de extraer archivos
        for subcarpeta in subcarpetas:
            ruta_subcarpeta = os.path.join(carpeta_actual, subcarpeta)
            if not os.listdir(ruta_subcarpeta):
                # Si la subcarpeta está vacía, eliminarla
                os.rmdir(ruta_subcarpeta)

# Ruta del directorio donde se encuentran las carpetas
directorio_principal = output_folder

# Llamada a la función para extraer archivos y eliminar carpetas vacías
extraer_y_eliminar_carpeta_vacia(directorio_principal)



# In[9]:


import pandas as pd
# Obtén la lista de archivos CSV en el directorio
archivos_csv = [archivo for archivo in os.listdir(output_folder) if archivo.endswith('.csv')]

# Inicializar dataframes vacíos para cada año
datos_2019 = pd.DataFrame()
datos_2020 = pd.DataFrame()
datos_2022 = pd.DataFrame()

# Loop para cargar y combinar los archivos por año
for archivo in archivos_csv:
    if '2019' in archivo:
        datos = pd.read_csv(os.path.join(output_folder, archivo), dtype={'columna5': str, 'columna7': str})
        datos_2019 = pd.concat([datos_2019, datos], ignore_index=True)
    elif '2020' in archivo:
        datos = pd.read_csv(os.path.join(output_folder, archivo), dtype={'columna5': str, 'columna7': str})
        datos_2020 = pd.concat([datos_2020, datos], ignore_index=True)
    elif '2022' in archivo:
        datos = pd.read_csv(os.path.join(output_folder, archivo), dtype={'columna5': str, 'columna7': str})
        datos_2022 = pd.concat([datos_2022, datos], ignore_index=True)


# In[12]:


# Hacemos una muestra para evitar trabajar con toda la información

datos_2019 = datos_2019.sample(frac=0.2)
datos_2020 = datos_2020.sample(frac=0.2)
datos_2022 = datos_2022.sample(frac=0.2)


# In[18]:


# Descargamos este dataframes a una directorio para el futuro análisis en R Studio

directorio_local = r'C:\Users\alfre\OneDrive\Documentos\5º Carrera\TFG\TFG Business Analytics\R Studio\Initial_Data'

if not os.path.exists(directorio_local):
    os.makedirs(directorio_local)

# Guarda los dataframes en archivos CSV
datos_2019.to_csv(os.path.join(directorio_local, 'datos_2019.csv'), index=False)
datos_2020.to_csv(os.path.join(directorio_local, 'datos_2020.csv'), index=False)
datos_2022.to_csv(os.path.join(directorio_local, 'datos_2022.csv'), index=False)

