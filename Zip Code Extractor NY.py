#!/usr/bin/env python
# coding: utf-8

# In[1]:


pip install geopy


# In[13]:


import os
import pandas as pd
from geopy.geocoders import Bing

directorio = r'C:\Users\alfre\OneDrive\Documentos\5º Carrera\TFG\TFG Business Analytics\R Studio\Initial_Data'
archivo19 = 'datos_2019.csv'
archivo20 = 'datos_2020.csv'
archivo22 = 'datos_2022.csv'

ruta_completa19 = os.path.join(directorio, archivo19)
ruta_completa20 = os.path.join(directorio, archivo20)
ruta_completa22 = os.path.join(directorio, archivo22)

datos_19 = pd.read_csv(ruta_completa19, low_memory=False)
datos_20 = pd.read_csv(ruta_completa20, low_memory=False)
datos_22 = pd.read_csv(ruta_completa22, low_memory=False)


# In[ ]:





# ## Extracción de los zipcodes del dataset 2019

# In[5]:


# Creamos un dataset con las estaciones únicas y sus coordenadas de inicio y fin de trayecto. Hacemos un groupby y que encuentre el primer valor de lat, long de cada grupo. Cambiamos el nombre de la variable común para luego hacer un merge con esa clave.

start_station_to_coordinates19 = datos_19.groupby('start station name')[['start station latitude', 'start station longitude']].first().reset_index().rename(columns= {'start station name':'unique_station'})
end_station_to_coordinates19 = datos_19.groupby('end station name')[['end station latitude', 'end station longitude']].first().reset_index().rename(columns= {'end station name':'unique_station'})

data_19 = pd.merge(start_station_to_coordinates19, end_station_to_coordinates19, on='unique_station', how='outer')

# Observamos si hay valores nulos en las coordendas de inicio

start_nulls19 = data_19['start station latitude'].isnull().sum() + data_19['start station longitude'].isnull().sum()
end_nulls19 = data_19['end station latitude'].isnull().sum() + data_19['end station longitude'].isnull().sum()

print("Los valores nulos en las cordendas start son:", {start_nulls19}, "y los de las coordenadas finales son:", {end_nulls19})


# In[6]:


# Tras comprobar que todos coinciden las coordenadas de inicio y fin, nos quedamos con las coordenadas de fin porque están completas

data_19 = data_19.drop(columns = ["start station latitude", "start station longitude"])

# Cambiamos el nonmbre a las variables "end station latitude" y "end station longitude"
                                                                             
data_19.rename(columns={'end station latitude': 'latitude'}, inplace=True)
data_19.rename(columns={'end station longitude': 'longitude'}, inplace=True)


# In[7]:


from geopy.geocoders import Bing

api_key = "AqBy_7AyPPxoBtk6c6RV9KAZUYjwC5nWn6LTZw9OGAQmIJgZCv8kLdtdnzt-nBvD"

geolocator = Bing(api_key=api_key)

def get_zipcodes(row):
    location = geolocator.reverse((row['latitude'], row['longitude']), exactly_one=True)
    zipcode = location.raw['address'].get('postalCode', None)
    city = location.raw['address'].get('adminDistrict', None)
    return zipcode, city

data_19[['zipcode', 'city']] = data_19.apply(get_zipcodes, axis=1, result_type='expand')
data_19


# In[6]:


# Procedemos a hacer el reverse geocoding de estas estaciones para conseguir su zipcode

# Definimos clave API de Bing Maps
api_key = "Ao3isFW6vrIivL7220YlotYUBDrPm_5Om-X4ELtAya0pfeM93Wmh_lYIRNEZtOMy"

# Creamos una instancia del geocoder de Bing Maps
geolocator = Bing(api_key=api_key)

# Función para obtener los zipcodes de inicio y fin
def get_zipcodes(row):
    location = geolocator.reverse((row['latitude'], row['longitude']), exactly_one=True)
    zipcode = location.raw['address'].get('postalCode', None)
    city = location.raw['address'].get('adminDistrict', None)
    return location

# Aplicar la función para obtener los zipcodes y agregarlos como nuevas columnas al dataframe

n = data_19.apply(get_zipcodes, axis=1, result_type='expand')
n


# In[8]:


# Finalmente procedemos a asignar a cada observacion del dataset inicial su zip code
# Para ello, transformamos nuestro dataset con los dock names únicos y su zipcode en un diccionario usando las estaciones como clave y el zipcode como valor

dic_19_zc = data_19.set_index('unique_station')['zipcode'].to_dict()
dic_19_ct = data_19.set_index('unique_station')['city'].to_dict()

# Creamos las variables start zip y end zip en el dataset inicial para después asignarle a cada variable el zipcode correspondiente

datos_19['start_zip'] = datos_19['start station name'].map(dic_19_zc)
datos_19['end_zip'] = datos_19['end station name'].map(dic_19_zc)
datos_19['start_city'] = datos_19['start station name'].map(dic_19_ct)
datos_19['end_city'] = datos_19['end station name'].map(dic_19_ct)

datos_19


# ## Extracción de los zipcodes del dataset 2020

# In[9]:


# Creamos un dataset con las estaciones únicas y sus coordenadas de inicio y fin de trayecto. Hacemos un groupby y que encuentre el primer valor de lat, long de cada grupo. Cambiamos el nombre de la variable común para luego hacer un merge con esa clave.

start_station_to_coordinates20 = datos_20.groupby('start station name')[['start station latitude', 'start station longitude']].first().reset_index().rename(columns= {'start station name':'unique_station'})
end_station_to_coordinates20 = datos_20.groupby('end station name')[['end station latitude', 'end station longitude']].first().reset_index().rename(columns= {'end station name':'unique_station'})

data_20 = pd.merge(start_station_to_coordinates20, end_station_to_coordinates20, on='unique_station', how='outer')

# Observamos si hay valores nulos en las coordendas de inicio

start_nulls20 = data_20['start station latitude'].isnull().sum() + data_20['start station longitude'].isnull().sum()
end_nulls20 = data_20['end station latitude'].isnull().sum() + data_20['end station longitude'].isnull().sum()

print("Los valores nulos en las cordendas start son:", {start_nulls20}, "y los de las coordenadas finales son:", {end_nulls20})


# In[13]:


#Tenemos una estación en el dataset de 2020 donde la longitud y latitud es cero, tras examinarla, vemos que es "Liberty State Park". Al ver la ubicación en maps, vemos que no existe ningun dock de bicicletas citi y por tanto procedo a aproximar las coordenadas a la estación más cercana que es "Liberty Light Rail"

# Identificamos la posición de índice que toma la variable que queremos cambiar (la que tiene latitud = 0)

index1 = data_20.index[data_20['unique_station'] == "Liberty State Park"][0]
index2 = data_20.index[data_20['unique_station'] == "Liberty Light Rail"][0]
    
data_20_index2 = data_20.loc[index2, ['start station latitude', 'start station longitude', 'end station latitude', 'end station longitude']]
data_20.loc[index1, ['start station latitude', 'start station longitude', 'end station latitude', 'end station longitude']] = data_20_index2

data_20.iloc[index1]


# In[10]:


# Procedemos a eliminar los valores nulos de las coordenadas finales

# Tras comprobar que todos coinciden las coordenadas de inicio y fin, nos quedamos con las coordenadas de fin porque están completas

data_20 = data_20.drop(columns = ["start station latitude", "start station longitude"])

# Cambiamos el nonmbre a las variables "end station latitude" y "end station longitude"
                                                                             
data_20.rename(columns={'end station latitude': 'latitude'}, inplace=True)
data_20.rename(columns={'end station longitude': 'longitude'}, inplace=True)


# In[11]:


# Procedemos a hacer el reverse geocoding de estas estaciones para conseguir su zipcode

# Definimos clave API de Bing Maps
api_key = "AqBy_7AyPPxoBtk6c6RV9KAZUYjwC5nWn6LTZw9OGAQmIJgZCv8kLdtdnzt-nBvD"

# Crear una instancia del geocoder de Bing Maps
geolocator = Bing(api_key=api_key)

# Función para obtener los zipcodes de inicio y fin
def get_zipcodes(row):
    location = geolocator.reverse((row['latitude'], row['longitude']), exactly_one=True)
    zipcode = location.raw['address'].get('postalCode', None)
    city = location.raw['address'].get('adminDistrict', None)
    return zipcode, city

# Aplicar la función para obtener los zipcodes y agregarlos como nuevas columnas al dataframe

data_20[['zipcode', 'city']] = data_20.apply(get_zipcodes, axis=1, result_type='expand')
data_20


# In[12]:


# Finalmente procedemos a asignar a cada observacion del dataset inicial su zip code
# Para ello, transformamos nuestro dataset con los dock names únicos y su zipcode en un diccionario usando las estaciones como clave y el zipcode como valor

dic_20_zc = data_20.set_index('unique_station')['zipcode'].to_dict()
dic_20_ct = data_20.set_index('unique_station')['city'].to_dict()

# Creamos las variables start zip y end zip en el dataset inicial para después asignarle a cada variable el zipcode correspondiente

datos_20['start_zip'] = datos_20['start station name'].map(dic_20_zc)
datos_20['end_zip'] = datos_20['end station name'].map(dic_20_zc)
datos_20['start_city'] = datos_20['start station name'].map(dic_20_ct)
datos_20['end_city'] = datos_20['end station name'].map(dic_20_ct)

datos_20


# ## Extracción de los zipcodes del dataset 2022

# In[3]:


# Creamos un dataset con las estaciones únicas y sus coordenadas de inicio y fin de trayecto. Hacemos un groupby y que encuentre el primer valor de lat, long de cada grupo. Cambiamos el nombre de la variable común para luego hacer un merge con esa clave.

start_station_to_coordinates22 = datos_22.groupby('start_station_name')[['start_lat', 'start_lng']].first().reset_index().rename(columns= {'start_station_name':'unique_station'})
end_station_to_coordinates22 = datos_22.groupby('end_station_name')[['end_lat', 'end_lng']].first().reset_index().rename(columns= {'end_station_name':'unique_station'})

data_22 = pd.merge(start_station_to_coordinates22, end_station_to_coordinates22, on='unique_station', how='outer')

# Observamos si hay valores nulos en las coordendas de inicio

start_nulls22 = data_22['start_lat'].isnull().sum() + data_22['start_lng'].isnull().sum()
end_nulls22 = data_22['end_lat'].isnull().sum() + data_22['end_lng'].isnull().sum()

print("Los valores nulos en las cordendas start son:", {start_nulls22}, "y los de las coordenadas finales son:", {end_nulls22})
                                                                             


# In[4]:


# Tras comprobar que todos coinciden las coordenadas de inicio y fin, nos quedamos con las coordenadas de fin porque están completas

data_22 = data_22.drop(columns = ["start_lat", "start_lng"])

# Cambiamos el nonmbre a las variables "end station latitude" y "end station longitude"
                                                                             
data_22.rename(columns={'end_lat': 'latitude'}, inplace=True)
data_22.rename(columns={'end_lng': 'longitude'}, inplace=True)


# In[5]:


# Procedemos a hacer el reverse geocoding de estas estaciones para conseguir su zipcode

# Definimos clave API de Bing Maps
api_key = "AqBy_7AyPPxoBtk6c6RV9KAZUYjwC5nWn6LTZw9OGAQmIJgZCv8kLdtdnzt-nBvD"

# Creamos una instancia del geocoder de Bing Maps
geolocator = Bing(api_key=api_key)

# Función para obtener los zipcodes de inicio y fin
def get_zipcodes(row):
    location = geolocator.reverse((row['latitude'], row['longitude']), exactly_one=True)
    zipcode = location.raw['address'].get('postalCode', None)
    city = location.raw['address'].get('adminDistrict', None)
    return zipcode, city

# Aplicar la función para obtener los zipcodes y agregarlos como nuevas columnas al dataframe

data_22[['zipcode', 'city']] = data_22.apply(get_zipcodes, axis=1, result_type='expand')
data_22


# In[6]:


directorio_local = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data'

if not os.path.exists(directorio_local):
    os.makedirs(directorio_local)

# Guardamos los dataframes en archivos CSV
data_22.to_csv(os.path.join(directorio_local, 'Estaciones_unicas_2022.csv'), index=False)


# In[17]:


# Finalmente procedemos a asignar a cada observaciñon del dataset inicial su zip code
# Para ello, transformamos nuestro dataset con los dock names únicos y su zipcode en un diccionario usando las estaciones como clave y el zipcode como valor

dic_22_zc = data_22.set_index('unique_station')['zipcode'].to_dict()
dic_22_ct = data_22.set_index('unique_station')['city'].to_dict()

# Creamos las variables start zip y end zip en el dataset inicial para después asignarle a cada variable el zipcode correspondiente

datos_22['start_zip'] = datos_22['start_station_name'].map(dic_22_zc)
datos_22['end_zip'] = datos_22['end_station_name'].map(dic_22_zc)
datos_22['start_city'] = datos_22['start_station_name'].map(dic_22_ct)
datos_22['end_city'] = datos_22['end_station_name'].map(dic_22_ct)

datos_22


# ## Comprobaciones

# In[18]:


zipnulls19 = datos_19['start_zip'].isnull().sum() + datos_19['end_zip'].isnull().sum()
zipnulls20 = datos_20['start_zip'].isnull().sum() + datos_20['end_zip'].isnull().sum()
zipnulls22 = datos_22['start_zip'].isnull().sum() + datos_22['end_zip'].isnull().sum()

print("el dataset de 2019 tiene:", {zipnulls19}, "valores nulos entre las variables zipcode", "\n"
     "el dataset de 2020 tiene:", {zipnulls20}, "valores nulos entre las variables zipcode", "\n"
      "el dataset de 2022 tiene:", {zipnulls22}, "valores nulos entre las variables zipcode")


# In[33]:


# Inspeccionamos los valores nulos del dataset de 2020

subset_22 = datos_22.loc[datos_22['end_station_name'].isnull(), ['end_station_name','end_lat','end_lng']].drop_duplicates().dropna(how = 'all').reset_index(drop = True)
subset_22


# In[34]:


# Tras comprobar que solo son 3000 observaciones en más de 800.000, ignoramos esos valores nulos.

datos_22 = datos_22.dropna(subset=['end_station_name'])


# # Distancia entre estaciones

# In[35]:


from math import radians, sin, cos, sqrt, atan2


def haversine(lat1, lon1, lat2, lon2):
    radio_tierra = 6371.0
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distancia = radio_tierra * c
    return distancia

datos_19['distance_km'] = datos_19.apply(lambda row: haversine(row['start station latitude'], row['start station longitude'], row['end station latitude'], row['end station longitude']), axis=1)


# In[36]:


from math import radians, sin, cos, sqrt, atan2


def haversine(lat1, lon1, lat2, lon2):
    radio_tierra = 6371.0
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distancia = radio_tierra * c
    return distancia

datos_20['distance_km'] = datos_20.apply(lambda row: haversine(row['start station latitude'], row['start station longitude'], row['end station latitude'], row['end station longitude']), axis=1)


# In[37]:


from math import radians, sin, cos, sqrt, atan2


def haversine(lat1, lon1, lat2, lon2):
    radio_tierra = 6371.0
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distancia = radio_tierra * c
    return distancia

datos_22['distance_km'] = datos_22.apply(lambda row: haversine(row['start_lat'], row['start_lng'], row['end_lat'], row['end_lng']), axis=1)


# # Creamos variable de velocidad media

# In[38]:


# Primero creamos la variable "tripduration en el año 2022" restando las variables "ended_at" y "started_at" y lo expresamos en segundos
datos_22['tripduration'] = (pd.to_datetime(datos_22['ended_at']) - pd.to_datetime(datos_22['started_at'])).dt.total_seconds()


datos_19['average_speed'] = datos_19.apply(lambda row: row['distance_km'] / (row['tripduration']/3600) if row['tripduration'] > 0 else None, axis=1)
datos_20['average_speed'] = datos_20.apply(lambda row: row['distance_km'] / (row['tripduration']/3600) if row['tripduration'] > 0 else None, axis=1)
datos_22['average_speed'] = datos_22.apply(lambda row: row['distance_km'] / (row['tripduration']/3600) if row['tripduration'] > 0 else None, axis=1)


# ## Extracción de los datasets a una ruta local

# In[39]:


# Descargamos este dataframes a una directorio para el futuro análisis en R Studio

directorio_local = r'C:\Users\alfre\OneDrive\Documentos\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data'

if not os.path.exists(directorio_local):
    os.makedirs(directorio_local)

# Guarda los dataframes en archivos CSV
datos_19.to_csv(os.path.join(directorio_local, 'datos_2019_vf.csv'), index=False)
datos_20.to_csv(os.path.join(directorio_local, 'datos_2020_vf.csv'), index=False)
datos_22.to_csv(os.path.join(directorio_local, 'datos_2022_vf.csv'), index=False)


# ## Estadísticos

# In[17]:


resumen_estadistico19 = round(datos_19[['tripduration', 'birth year', 'gender']].describe(),1)
resumen_estadistico20 = round(datos_20[['tripduration', 'birth year', 'gender']].describe(),1)
#resumen_estadistico22 = round(datos_22[['tripduration', 'birth year', 'gender']].describe(),1)

resumen_estadistico19.columns = [col + '_2019' for col in resumen_estadistico19.columns]
resumen_estadistico20.columns = [col + '_2020' for col in resumen_estadistico20.columns]

# Concatenar los dataframes horizontalmente
resumen_conjunto = pd.concat([resumen_estadistico19, resumen_estadistico20], axis=1)
resumen_conjunto


# # Clasificación de las coordenadas

# In[41]:


import os
import pandas as pd
from geopy.geocoders import Bing

directorio = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data'
archivo19 = 'datos_2019_vf.csv'
archivo20 = 'datos_2020_vf.csv'
archivo22 = 'datos_2022_vf.csv'

ruta_completa19 = os.path.join(directorio, archivo19)
ruta_completa20 = os.path.join(directorio, archivo20)
ruta_completa22 = os.path.join(directorio, archivo22)

datos_19 = pd.read_csv(ruta_completa19, low_memory=False)
datos_20 = pd.read_csv(ruta_completa20, low_memory=False)
datos_22 = pd.read_csv(ruta_completa22, low_memory=False)


# In[42]:


datos_22


# In[43]:


datos_19.rename(columns={'start station latitude': 'latitude'}, inplace=True)
datos_19.rename(columns={'start station longitude': 'longitude'}, inplace=True)
datos_19.rename(columns={'end station latitude': 'latitude2'}, inplace=True)
datos_19.rename(columns={'end station longitude': 'longitude2'}, inplace=True)

datos_20.rename(columns={'start station latitude': 'latitude'}, inplace=True)
datos_20.rename(columns={'start station longitude': 'longitude'}, inplace=True)
datos_20.rename(columns={'end station latitude': 'latitude2'}, inplace=True)
datos_20.rename(columns={'end station longitude': 'longitude2'}, inplace=True)

datos_22.rename(columns={'start_lat': 'latitude'}, inplace=True)
datos_22.rename(columns={'start_lng': 'longitude'}, inplace=True)
datos_22.rename(columns={'end_lat': 'latitude2'}, inplace=True)
datos_22.rename(columns={'end_lng': 'longitude2'}, inplace=True)


# In[44]:


latitud_centro = 40.7433660802702  # Ejemplo: Times Square
longitud_centro = -73.95960688591

def clasificar_estacion(row, latitud_centro, longitud_centro):
    latitud = row['latitude']
    longitud = row['longitude']
    
    
    if (latitud - latitud_centro) >= abs(longitud - longitud_centro):
        return 'North'
    elif (latitud - latitud_centro) <= -abs(longitud - longitud_centro):
        return 'South'
    elif longitud > longitud_centro:
        return 'East'
    else:
        return 'West'

# Aplicar la función de clasificación a cada fila del DataFrame

datos_19['start_geography'] = datos_19.apply(clasificar_estacion, axis=1, result_type='expand', args = (latitud_centro, longitud_centro))
datos_20['start_geography'] = datos_20.apply(clasificar_estacion, axis=1, result_type='expand', args = (latitud_centro, longitud_centro))
datos_22['start_geography'] = datos_22.apply(clasificar_estacion, axis=1, result_type='expand', args = (latitud_centro, longitud_centro))


# In[45]:


latitud_centro = 40.7433660802702  # Ejemplo: Times Square
longitud_centro = -73.95960688591

def clasificar_estacion(row, latitud_centro, longitud_centro):
    latitud = row['latitude2']
    longitud = row['longitude2']
    
    
    if (latitud - latitud_centro) >= abs(longitud - longitud_centro):
        return 'North'
    elif (latitud - latitud_centro) <= -abs(longitud - longitud_centro):
        return 'South'
    elif longitud > longitud_centro:
        return 'East'
    else:
        return 'West'


datos_19['end_geography'] = datos_19.apply(clasificar_estacion, axis=1, result_type='expand', args = (latitud_centro, longitud_centro))
datos_20['end_geography'] = datos_20.apply(clasificar_estacion, axis=1, result_type='expand', args = (latitud_centro, longitud_centro))
datos_22['end_geography'] = datos_22.apply(clasificar_estacion, axis=1, result_type='expand', args = (latitud_centro, longitud_centro))


# In[46]:


datos_19.rename(columns={'latitude': 'start station latitude'}, inplace=True)
datos_19.rename(columns={'longitude': 'start station longitude'}, inplace=True)
datos_19.rename(columns={'latitude2': 'end station latitude'}, inplace=True)
datos_19.rename(columns={'longitude2': 'end station longitude'}, inplace=True)

datos_20.rename(columns={'latitude': 'start station latitude'}, inplace=True)
datos_20.rename(columns={'longitude': 'start station longitude'}, inplace=True)
datos_20.rename(columns={'latitude2': 'end station latitude'}, inplace=True)
datos_20.rename(columns={'longitude2': 'end station longitude'}, inplace=True)

datos_22.rename(columns={'latitude': 'start_lat'}, inplace=True)
datos_22.rename(columns={'longitude': 'start_lng'}, inplace=True)
datos_22.rename(columns={'latitude2': 'end_lat'}, inplace=True)
datos_22.rename(columns={'longitude2': 'end_lng'}, inplace=True)


# In[47]:


directorio_local = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data'


# Guarda los dataframes en archivos CSV
datos_19.to_csv(os.path.join(directorio_local, 'datos_2019_vf.csv'), index=False)
datos_20.to_csv(os.path.join(directorio_local, 'datos_2020_vf.csv'), index=False)
datos_22.to_csv(os.path.join(directorio_local, 'datos_2022_vf.csv'), index=False)


# In[5]:


import os
import pandas as pd

directorio = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data'

archivoZP = 'ZipsNY.xlsx'

ruta_completa_ZP = os.path.join(directorio, archivoZP)
datos_ZP = pd.read_excel(ruta_completa_ZP)


# In[6]:


datos_ZP


# In[12]:


resumen_estadistico_ZP = round(datos_ZP[['population', 'median_age', 'rent', 'commute_time_to_work']].describe(),1)
resumen_estadistico_ZP

