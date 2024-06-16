#!/usr/bin/env python
# coding: utf-8

# In[1]:


pip install pyarrow


# In[5]:


import pandas as pd

import os
import pandas as pd
from geopy.geocoders import Bing

directorio = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data\Feathers'
archivo19 = 'datos_2019_graph_parte_{}.feather'
num_partes = 7

ruta_completa19 = os.path.join(directorio, archivo19)

dataframes = []



for i in range(1, num_partes + 1):
    archivo = archivo19.format(i)
    ruta_completa = os.path.join(directorio, archivo)
    try:
        df_parte = pd.read_feather(ruta_completa)
        dataframes.append(df_parte)
        print(f'Successfully loaded {archivo}')
    except Exception as e:
        print(f'Failed to load {archivo}: {e}')


if dataframes:
    datos_2019 = pd.concat(dataframes, ignore_index=True)
    print('All parts combined successfully.')
else:
    print('No dataframes were loaded.')


# In[3]:


import pandas as pd

import os
import pandas as pd
from geopy.geocoders import Bing

directorio = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data\Feathers'
archivo20 = 'datos_2020_graph_parte_{}.feather'
num_partes = 7
ruta_completa20 = os.path.join(directorio, archivo20)

dataframes = []


for i in range(1, num_partes + 1):
    archivo = archivo20.format(i)
    ruta_completa = os.path.join(directorio, archivo)
    try:
        df_parte = pd.read_feather(ruta_completa)
        dataframes.append(df_parte)
        print(f'Successfully loaded {archivo}')
    except Exception as e:
        print(f'Failed to load {archivo}: {e}')

if dataframes:
    datos_2020 = pd.concat(dataframes, ignore_index=True)
    print('All parts combined successfully.')
else:
    print('No dataframes were loaded.')


# In[5]:


import pandas as pd

import os
import pandas as pd
from geopy.geocoders import Bing

directorio = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data\Feathers'
archivo22 = 'datos_2022_graph_parte_{}.feather'
num_partes = 11
ruta_completa22 = os.path.join(directorio, archivo22)

dataframes = []



for i in range(1, num_partes + 1):
    archivo = archivo22.format(i)
    ruta_completa = os.path.join(directorio, archivo)
    try:
        df_parte = pd.read_feather(ruta_completa)
        dataframes.append(df_parte)
        print(f'Successfully loaded {archivo}')
    except Exception as e:
        print(f'Failed to load {archivo}: {e}')


if dataframes:
    datos_2022 = pd.concat(dataframes, ignore_index=True)
    print('All parts combined successfully.')
else:
    print('No dataframes were loaded.')


# In[8]:


directorio_vf = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data\PowerBI'

datos_2019.to_csv(os.path.join(directorio_vf, 'datos_2019_graph.csv'), index=False)
datos_2020.to_csv(os.path.join(directorio_vf, 'datos_2020_graph.csv'), index=False)
datos_2022.to_csv(os.path.join(directorio_vf, 'datos_2022_graph.csv'), index=False)

