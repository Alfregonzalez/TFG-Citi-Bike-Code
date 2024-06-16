#!/usr/bin/env python
# coding: utf-8

# In[1]:


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


# In[2]:


datos_19[['start station name', 'end station name', 'start_geography', 'end_geography']]


# In[3]:


# Norte
count_norte_norte = datos_19[(datos_19['start_geography'] == 'North') & (datos_19['end_geography'] == 'North')].shape[0]
count_norte_sur = datos_19[(datos_19['start_geography'] == 'North') & (datos_19['end_geography'] == 'South')].shape[0]
count_norte_este = datos_19[(datos_19['start_geography'] == 'North') & (datos_19['end_geography'] == 'East')].shape[0]
count_norte_oeste = datos_19[(datos_19['start_geography'] == 'North') & (datos_19['end_geography'] == 'West')].shape[0]

# Sur
count_sur_norte = datos_19[(datos_19['start_geography'] == 'South') & (datos_19['end_geography'] == 'North')].shape[0]
count_sur_sur = datos_19[(datos_19['start_geography'] == 'South') & (datos_19['end_geography'] == 'South')].shape[0]
count_sur_este = datos_19[(datos_19['start_geography'] == 'South') & (datos_19['end_geography'] == 'East')].shape[0]
count_sur_oeste = datos_19[(datos_19['start_geography'] == 'South') & (datos_19['end_geography'] == 'West')].shape[0]

# Este
count_este_norte = datos_19[(datos_19['start_geography'] == 'East') & (datos_19['end_geography'] == 'North')].shape[0]
count_este_sur = datos_19[(datos_19['start_geography'] == 'East') & (datos_19['end_geography'] == 'South')].shape[0]
count_este_este = datos_19[(datos_19['start_geography'] == 'East') & (datos_19['end_geography'] == 'East')].shape[0]
count_este_oeste = datos_19[(datos_19['start_geography'] == 'East') & (datos_19['end_geography'] == 'West')].shape[0]

# Oeste
count_oeste_norte = datos_19[(datos_19['start_geography'] == 'West') & (datos_19['end_geography'] == 'North')].shape[0]
count_oeste_sur = datos_19[(datos_19['start_geography'] == 'West') & (datos_19['end_geography'] == 'South')].shape[0]
count_oeste_este = datos_19[(datos_19['start_geography'] == 'West') & (datos_19['end_geography'] == 'East')].shape[0]
count_oeste_oeste = datos_19[(datos_19['start_geography'] == 'West') & (datos_19['end_geography'] == 'West')].shape[0]


# In[4]:


from itertools import product

geographies = ['Norte', 'Sur', 'Este', 'Oeste']
combinations = list(product(geographies, repeat=2))
viajes = pd.DataFrame(combinations, columns=['start_geography', 'end_geography'])
viajes


# In[5]:


trips = [count_norte_norte, count_norte_sur, count_norte_este, count_norte_oeste, count_sur_norte, count_sur_sur, count_sur_este,
        count_sur_oeste, count_este_norte, count_este_sur, count_este_este, count_este_oeste, count_oeste_norte, count_oeste_sur,
        count_oeste_este, count_oeste_oeste]

viajes['trips'] = pd.DataFrame(trips, columns=['trips'])

start_lat = [40.82462402899655, 40.82530199265885, 40.825384646344865, 40.825264337948690, 40.67896484921727, 40.67209992429862, 40.67871065471062, 40.67359384379683, 40.726402497524894, 40.714446274569305, 40.72106098330365, 40.71580807328199, 40.723369511686975, 40.71541670718402, 40.726076543006755, 40.721579822242845]
start_lng= [-73.94248207221756, -73.9516888924922, -73.93353782602672, -73.95170361792718, -73.96194590188952, -73.96400558133254, -73.96035613318281, -73.97271647114917, -73.92147784821138, -73.91638083089867, -73.91774089081183, -73.92937710914225, -73.9827420631893, -73.98497043573528,  -73.98455742305050, -73.99167139679437]


end_lat = [40.82462402899655, 40.67366598659992, 40.72649339708628, 40.72530210327781, 40.81689177981529, 40.67209992429862, 40.71623166322353, 40.71431890989037, 40.817900575184865, 40.67275631189206, 40.72106098330365, 40.71758529005499, 40.817628741114824, 40.679270678263215, 40.722008451152995, 40.721579822242845]
end_lng= [-73.94248207221756, -73.97344567838738, -73.91196885650781, -73.99991297535735, -73.93959795883357, -73.96400558133254, -73.923515487321, -73.99463946842103, -73.94004476364795, -73.9544996057451, -73.91774089081183, -73.98583784360913, -73.94200699405454, -73.96608490803692, -73.92653359921559, -73.99167139679437]


viajes['start_lat'] = start_lat
viajes['start_lng'] = start_lng

viajes['end_lat'] = end_lat
viajes['end_lng'] = end_lng
viajes


# In[7]:


import math
import folium

center_lat = 40.7128
center_lng = -74.006
color = 'red'

# Coordenadas norte
n_lat = 40.82462402899655
n_lng = -73.94248207221756

# Coordenadas sur
s_lat = 40.67209992429862
s_lng = -73.96400558133254

# Coordenadas este
e_lat = 40.72106098330365
e_lng = -73.91774089081183

# Coordenadas oeste
w_lat = 40.721579822242845
w_lng = -73.99167139679437


# Creamos el mapa
map = folium.Map(location=[center_lat, center_lng], zoom_start=11.2, tiles='CartoDB positron')

# Creamos círculos alrededor de las coordenadas base
folium.Circle(
    location=[n_lat, n_lng],  # Coordenadas del centro
    radius= 800,  # Radio en metros
    color='blue',
    fill=True,
    fill_color='blue',
    fill_opacity=0.3,
    tooltip='North'
).add_to(map)

folium.Circle(
    location=[s_lat, s_lng],  # Coordenadas del centro
    radius= 800,  # Radio en metros
    color='green',
    fill=True,
    fill_color='green',
    fill_opacity=0.3,
    tooltip='South'
).add_to(map)

folium.Circle(
    location=[e_lat, e_lng],  # Coordenadas del centro
    radius= 800,  # Radio en metros
    color='black',
    fill=True,
    fill_color='black',
    fill_opacity=0.3,
    tooltip='East'
).add_to(map)

folium.Circle(
    location=[w_lat, w_lng],  # Coordenadas del centro
    radius= 800,  # Radio en metros
    color='red',
    fill=True,
    fill_color='red',
    fill_opacity=0.3,
    tooltip='West'
).add_to(map)

def add_arrow(map, start_lat, start_lng, end_lat, end_lng, weight, color=color):
    # Añadir la línea
    folium.PolyLine(
        locations=[[start_lat, start_lng], [end_lat, end_lng]],
        color=color,
        weight=weight/50000,
        fill_opacity=1
    ).add_to(map)

    # Calculamos el ángulo de la flecha
    angle = math.degrees(math.atan2(end_lat - start_lat, end_lng - start_lng))

# Añadir las flechas al mapa
for _, row in viajes.iterrows():
    if row['start_geography'] != row['end_geography']:
        if row['start_geography'] == 'Norte':
            color = 'blue'
        elif row['start_geography'] == 'Sur':
            color = 'green'
        elif row['start_geography'] == 'Este':
            color = 'black'
        elif row['start_geography'] == 'Oeste':
            color = 'red'
            
        add_arrow(
            map,
            row['start_lat'],
            row['start_lng'],
            row['end_lat'],
            row['end_lng'],
            row['trips'],
            color = color
        )
        
# Guardar y mostrar el mapa
map.save('map.html')
map


# In[8]:


import folium

# Coordenadas de los centros de los cuadrados
coordinates = [
    (40.85231880093296, -73.9333726488808),
    (40.65031741242558, -73.9689032314134),
    (40.722240461765026, -73.89580716013981),
    (40.721105341065204, -74.04368761348013)
]

    
# Longitudes de los lados de los cuadrados en metros
side_lengths = [count_norte_norte/40000000, count_sur_sur/40000000, count_este_este/40000000, count_oeste_oeste/40000000]
colors = ['blue', 'green', 'black', 'red']

for i, (s_lat, s_lng) in enumerate(coordinates):
    side_length = side_lengths[i]
    color = colors[i]
   
    vertices = [
        (s_lat + side_length / 2, s_lng + side_length / 2),
        (s_lat + side_length / 2, s_lng - side_length / 2),
        (s_lat - side_length / 2, s_lng - side_length / 2),
        (s_lat - side_length / 2, s_lng + side_length / 2),



    folium.Polygon(
        locations=vertices,
        color=color,
        fill=True,
        fill_color=color,
        fill_opacity=0.3,
        tooltip=f'Square {i+1}'
    ).add_to(map)


map


output_path = r'C:\Users\alfre\OneDrive - Universidad Pontificia Comillas\Ordenador ACER\5º Carrera\TFG\TFG Business Analytics\R Studio\Final_Data\mapa_cuadrados.html'

map.save(output_path)

print(f"El mapa se ha guardado en: {output_path}")


# In[9]:


map


# In[96]:


import os
print(os.getcwd())


# In[12]:


pip install plotly


# In[11]:


import plotly.graph_objects as go


# In[19]:


# Definir los nodos
labels = ['Norte', 'Sur', 'Este', 'Oeste','Norte', 'Sur', 'Este', 'Oeste']

# Definir los enlaces
source = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3]  # Índice de los nodos de origen
target = [4, 5, 6, 7, 4, 5, 6, 7, 4, 5, 6, 7, 4, 5, 6, 7]  # Índice de los nodos de destino
value = [count_norte_norte, count_norte_sur, count_norte_este, count_norte_oeste, count_sur_norte, count_sur_sur, count_sur_este, count_sur_oeste, count_este_norte, count_este_sur, count_este_este, count_este_oeste, count_oeste_norte, count_oeste_sur, count_oeste_este, count_oeste_oeste]   # Valores de los flujos

# Crear el diagrama de Sankey
fig = go.Figure(data=[go.Sankey(
    node=dict(
        pad=15,  # Espacio entre nodos
        thickness=20,  # Grosor de los nodos
        line=dict(color="black", width=0.3),
        label=labels
    ),
    link=dict(
        source=source,
        target=target,
        value=value
    )
)])

fig.update_layout(title_text="Diagrama de Sankey", font_size=10)
fig.show()

