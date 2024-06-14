# TFG - ANÁLISIS DE LOS VIAJES DE BIKE SHARING DE CITI BIKE. ¿CÓMO HA AFECTADO LA PANDEMIA A ESTA PLATAFORMA?


# Instalamos y cargamos las librerías

install.packages('readxl')
install.packages('dplyr')
install.packages('readr')
install.packages('ggmap')
install.packages('ggcorrplot')
install.packages('corrplot')
install.packages('leaflet')
install.packages('cluster')
install.packages('factoextra')
install.packages('lubridate')
install.packages("vioplot")
install.packages("sf")
install.packages("writexl")
install.packages("arrow")
install.packages("car")


library(readxl)
library(dplyr)
library(readr)
library(ggmap)
library(ggcorrplot)
library(corrplot)
library(leaflet)
library(cluster)
library(factoextra)
library(lubridate)
library(ggplot2)
library(vioplot)
library(sf)
library(writexl)
library(arrow)
library(car)

# Establecemos directorio

setwd("C:/Users/alfre/OneDrive - Universidad Pontificia Comillas/Ordenador ACER/5º Carrera/TFG/TFG Business Analytics/R Studio/Final_Data")

# Importamos nuestros datasets desde el directorio

data_2019 <- read_csv("datos_2019_vf.csv")
data_2020 <- read_csv("datos_2020_vf.csv")
data_2022 <- read_csv("datos_2022_vf.csv")


# ========================== 1. INSPECCION DE LOS DATOS ==========================

# Principales estadísticos de los datasets

# Datos 2019

str(data_2019)
summary19 <- summary(data_2019)
sapply(data_2019, class)

# Datos 2020

str(data_2020)
summary(data_2020)
sapply(data_2020, class)

# Datos 2022

str(data_2022)
summary(data_2022)
sapply(data_2022, class)


# ======================= 2. TRATAMIENTO DE LOS DATOS ==========================


# 2.1 Tratamiento de valores nulos

# Omitimos los valores nulos (NAs)

datos_2019 <- na.omit(data_2019)
datos_2020 <- na.omit(data_2020)
datos_2022 <- na.omit(data_2022)

# Calculamos el número de valores nulos borrados de cada dataset

Nas2019 <- sum(is.na(data_2019)) - sum(is.na(na.omit(data_2019)))
Nas2020 <- sum(is.na(data_2020)) - sum(is.na(na.omit(data_2020)))
Nas2022 <- sum(is.na(data_2022)) - sum(is.na(na.omit(data_2022)))

cat("El número de NAs de 2019 es", Nas2019, ", el de 2020 es", Nas2020, "y el de 2022 es", Nas2022)



# 2.2 Sustituimos los espacios del nombre de las variables por "_"

new_colnames_2019 <- gsub(" ", "_", colnames(datos_2019))
colnames(datos_2019) <- new_colnames_2019

new_colnames_2020 <- gsub(" ", "_", colnames(datos_2020))
colnames(datos_2020) <- new_colnames_2020

new_colnames_2022 <- gsub(" ", "_", colnames(datos_2022))
colnames(datos_2022) <- new_colnames_2022




# 2.3 Estructura de las varibles


#  Comparación de las variables de los datasets

new_colnames_2019 # variables de 2019
new_colnames_2020 # variables de 2020
new_colnames_2022 # variables de 2022


# ==============================================================================

  # Las variables de 2019 y 2020 son las mismas. 
  # Sin embargo, en 2022 faltan variables como "tripduration", "bikeid" y "birth_year"

# ==============================================================================

# Estandarizamos las variables "user_type" y "member_casual en los datos de 2022"

datos_2022$usertype = ifelse(datos_2022$member_casual == "member", "Subscriber",
                            ifelse(datos_2022$member_casual == "casual", "Customer",
                                   datos_2022$member_casual))

# Eliminamos la variable original (member_casual)

datos_2022 <- subset(datos_2022, select = -member_casual)


# ==============================================================================
    
  # Observamos como la variable "tripduration" es negativa. 
  # Procedemos a examinar las observaciones con duración negativas

# ==============================================================================


subset_datos2022 <- subset(datos_2022, tripduration<0)


ids_to_delete_2022 <-subset_datos2022[1:4]

  # Hay una fecha en la que se producen muchas duraciones negativas. Es en 2022-11-06. Tras analizar esta fecha, he podido ver que en ese día se cambio la hora en Nueva York, por lo tanto, voy a sumar 1 hora (3600 segundos) a cada Tripduration
  # El resto de fechas las borramos ya que no se puede explicar porque tienen duración negativa. Probablemente sea por un fallo en la estacion de bicicletas


datos_2022[datos_2022$ride_id %in% subset_datos2022$ride_id, ]$tripduration <- subset_datos2022$tripduration + 3600

datos_2022 <- subset(datos_2022, !(ride_id %in% ids_to_delete_2022))

  
# 2.4 Eliminamos las variables de tipo caracter de nuestro dataset

# 2019
character_variable_2019 <- c("start_station_name", "end_station_name", "usertype", "bikeid", "gender", "start_zip", "end_zip", "start_city", "end_city")  # Lista de variables a eliminar
datos_2019_numeric <- datos_2019 %>% select(-one_of(character_variable_2019))

# 2020
character_variable_2020 <- c("start_station_name", "end_station_name", "usertype", "bikeid", "gender", "start_zip", "end_zip", "start_city", "end_city")  # Lista de variables a eliminar
datos_2020_numeric <- datos_2020 %>% select(-one_of(character_variable_2020))

# 2022
character_variable_2022 <- c("ride_id","rideable_type", "start_station_id","start_station_name", "end_station_id", "end_station_name", "usertype", "start_zip", "end_zip", "start_city", "end_city")  # Lista de variables a eliminar
datos_2022_numeric <- datos_2022 %>% select(-one_of(character_variable_2022))


# 2.5 Diagramas de violin de la variable Tripduration y Birth Year

# Tripduration

vioplot(datos_2019$tripduration, datos_2020$tripduration,
        names = c("2019", "2020"),
        col = c("lightblue", "lightgreen"),
        ylab = "Segundos")


# Birth Year

vioplot(datos_2019$birth_year, datos_2020$birth_year,
        names = c("2019", "2020"),
        col = c("lightblue", "lightgreen"),
        ylab = "Segundos")



# 2.6 Tratamiento de los outliers


# Variables en las que tiene sentido identificar y modificar outliers

# 2019
outlier_variable_2019 <- c("tripduration", "birth_year","distance_km", "average_speed")
datos_2019_outliers <- datos_2019 %>% select(one_of(outlier_variable_2019))


# 2020
outlier_variable_2020 <- c("tripduration", "birth_year","distance_km","average_speed")
datos_2020_outliers <- datos_2020 %>% select(one_of(outlier_variable_2020))

# 2022
outlier_variable_2022 <- c("tripduration","distance_km","average_speed")
datos_2022_outliers <- datos_2022 %>% select(one_of(outlier_variable_2022))


# Análisis de la variable distance y tripduration


datos_2019_outliers$distance_km <- ifelse(datos_2019_outliers$distance_km == 0 & datos_2019_outliers$tripduration > 60,
                                    datos_2019_outliers$tripduration/240, datos_2019_outliers$distance_km)

datos_2020_outliers$distance_km <- ifelse(datos_2020_outliers$distance_km == 0 & datos_2020_outliers$tripduration > 60,
                                    datos_2020_outliers$tripduration/240, datos_2020_outliers$distance_km)

datos_2022_outliers$distance_km <- ifelse(datos_2022_outliers$distance_km == 0 & datos_2022_outliers$tripduration > 60,
                                    datos_2022_outliers$tripduration/240, datos_2022_outliers$distance_km)



# Procedemos a tratar los outliers en funcion de las desviaciones sobre la media


num_desviaciones_std <- 2


# 2019
for (variable_name in names(datos_2019_outliers)) {
  
  variable_estandarizada_19 <- scale(datos_2019_outliers[[variable_name]])
  condicion_19 <- abs(variable_estandarizada_19) <= num_desviaciones_std
  new <- datos_2019_outliers[[variable_name]][!condicion_19] <- NA
}


datos_2019_graph <- datos_2019 %>% select(-one_of(outlier_variable_2019))
datos_2019_graph <- na.omit(cbind(datos_2019_outliers, datos_2019_graph))


# 2020

for (variable_name in names(datos_2020_outliers)) {
  
  variable_estandarizada_20 <- scale(datos_2020_outliers[[variable_name]])
  condicion_20 <- abs(variable_estandarizada_20) <= num_desviaciones_std
  datos_2020_outliers[[variable_name]][!condicion_20] <- NA
}


datos_2020_graph <- datos_2020 %>% select(-one_of(outlier_variable_2020))
datos_2020_graph <- na.omit(cbind(datos_2020_outliers, datos_2020_graph))

# 2022

for (variable_name in names(datos_2022_outliers)) {
  
  variable_estandarizada_22 <- scale(datos_2022_outliers[[variable_name]])
  condicion_22 <- abs(variable_estandarizada_22) <= num_desviaciones_std
  datos_2022_outliers[[variable_name]][!condicion_22] <- NA
}


datos_2022_graph <- datos_2022 %>% select(-one_of(outlier_variable_2022))
datos_2022_graph <- na.omit(cbind(datos_2022_outliers, datos_2022_graph))



# =============== 3. EVOLUCIÓN EN EL USO DE LAS BICIS DESPUÉS DE LA PANDEMIA ==========================

# 3.1 Gráficos de cada dataset

# 3.1.1 Histograma de la duracion de cada viaje

# 2019

histogram1_19<- hist(datos_2019_graph$tripduration, 
                   main = "Duración de los viajes 2019",
                   xlab = "Duración del viaje (segundos)",
                   ylab = "Frecuencia",
                   ylim = c(0, 650000),
                   xlim = c(0,2500),
                   col = "lightblue",  
                   border = "black",  
                   breaks = 20) 

# 2020

histogram1_20<- hist(datos_2020_graph$tripduration, 
                   main = "Duración de los viajes 2020",
                   xlab = "Duración del viaje (segundos)",
                   ylab = "Frecuencia",
                   ylim = c(0, 650000),
                   xlim = c(0,2500),
                   col = "lightgreen",  
                   border = "black",   
                   breaks = 20) 

# 2022

histogram1_22<- hist(datos_2022_graph$tripduration, 
                   main = "Duración de los viajes 2022",
                   xlab = "Duración del viaje (segundos)",
                   ylab = "Frecuencia",
                   ylim = c(0, 650000),
                   xlim = c(0,2500),
                   col = "lightpink", 
                   border = "black",   
                   breaks = 20) 

# 3.1.2 Histograma de los kilómetros de cada viaje

# 2019

histogram2_19<- hist(datos_2019_graph$distance_km, 
                   main = "Distancia de los viajes 2019",
                   xlab = "Kilómetros del viaje",
                   ylab = "Frecuencia",
                   ylim = c(0, 600000),
                   xlim = c(0,6),
                   col = "lightblue",  
                   border = "black",  
                   breaks = 20) 

# 2020

histogram2_20<- hist(datos_2020_graph$distance_km, 
                   main = "Distancia de los viajes 2020",
                   xlab = "Kilómetros del viaje",
                   ylab = "Frecuencia",
                   ylim = c(0, 600000),
                   xlim = c(0,6),
                   col = "lightgreen",  
                   border = "black",   
                   breaks = 20) 

# 2022

histogram2_22<- hist(datos_2022_graph$distance_km, 
                   main = "Distancia de los viajes 2022",
                   xlab = "Kilómetros del viaje",
                   ylab = "Frecuencia",
                   ylim = c(0, 600000),
                   xlim = c(0,6),
                   col = "lightpink", 
                   border = "black",   
                   breaks = 20) 


# 3.1.3 Uso de las bicilcletas hombre y mujer

#2019

gender_counts <- table(datos_2019_graph$gender)
barplot(gender_counts, col = c('lightblue','lightblue', 'lightblue'),
        main = 'Uso de las bicicletas por género 2019',
        xlab = 'Género', ylab = 'Frecuencia',
        ylim = c(0,2500000),
        yaxt = "n",
        names.arg = c('Unknown','Male', 'Female'))

axis(2, at = seq(0, 2500000, by = 200000), labels = format(seq(0, 2500000, by = 200000), format = "e", digits = 1))

proporcion_hombres <- gender_counts[2]/nrow(datos_2019_graph)
proporcion_mujeres <- gender_counts[3]/nrow(datos_2019_graph)
proporcion_unknown <- gender_counts[1]/nrow(datos_2019_graph)

#2020

gender_counts <- table(datos_2020_graph$gender)
barplot(gender_counts, col = c('lightgreen','lightgreen', 'lightgreen'),
        main = 'Uso de las bicicletas por género 2020',
        xlab = 'Género', ylab = 'Frecuencia',
        ylim = c(0,2500000),
        yaxt = "n",
        names.arg =c('Unknown','Male', 'Female'))

axis(2, at = seq(0, 2500000, by = 200000), labels = format(seq(0, 2500000, by = 200000), format = "e", digits = 1))

proporcion_hombres <- gender_counts[2]/nrow(datos_2019_graph)
proporcion_mujeres <- gender_counts[3]/nrow(datos_2019_graph)
proporcion_unknown <- gender_counts[1]/nrow(datos_2019_graph)

# En 2022 no tenemos la variable género (protección de datos)

# 3.1.4 ZipCodes en los que se han cogido más bicis

#2019
zip_counts <- table(datos_2019_graph$start_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,3)
barplot(zip_counts, col = "lightblue", main = 'ZipCodes de donde se recogen más bicis 2019', xlab = 'Start Zip Codes', ylab = 'Frecuencia')

#2020
zip_counts <- table(datos_2020_graph$start_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,3)
barplot(zip_counts, col = "lightgreen", main = 'ZipCodes de donde se recogen más bicis 2020', xlab = 'Start Zip Codes', ylab = 'Frecuencia')

#2022

zip_counts <- table(datos_2022_graph$start_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,3)
barplot(zip_counts, col = "lightpink", main = 'ZipCodes de donde se recogen más bicis 2022', xlab = 'Start Zip Codes', ylab = 'Frecuencia')

# 3.1.5 ZipCodes donde se han dejado más bicis

#2019
zip_counts <- table(datos_2019_graph$end_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,5)
barplot(zip_counts, col = "lightblue", main = 'ZipCodes de donde se dejan más bicis 2019', xlab = 'End Zip Codes', ylab = 'Frecuencia')

#2020
zip_counts <- table(datos_2020_graph$end_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,5)
barplot(zip_counts, col = "lightgreen", main = 'ZipCodes de donde se dejan más bicis 2020', xlab = 'End Zip Codes', ylab = 'Frecuencia')

#2022

zip_counts <- table(datos_2022_graph$end_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,5)
barplot(zip_counts, col = "lightpink", main = 'ZipCodes de donde se dejan más bicis 2022', xlab = 'End Zip Codes', ylab = 'Frecuencia')

# 3.1.6 Ciudad en la que se utilizan más las bicis

#2019
star_city_count <- table(datos_2019_graph$start_city)

#2020
star_city_count <- table(datos_2020_graph$start_city)

#2022
star_city_count <- table(datos_2022_graph$start_city)


# 3.1.7 Histograma de la velocidad media de los viajes

histogram3_19<- hist(datos_2019_graph$average_speed, 
                     main = "Velocidad media de los viajes 2019",
                     xlab = "KM/H",
                     ylab = "Frecuencia",
                     col = "lightblue",
                     ylim = c(0,450000),
                     xlim = c(0, 16),
                     xaxt = "n",
                     yaxt = "n",
                     border = "black",  
                     breaks = 30)

axis(1, at = seq(0, 18, by = 2))
axis(2, at = seq(0, 350000, by = 50000), labels = format(seq(0, 350000, by = 50000), format = "e", digits = 1))

# 2020

histogram3_20<- hist(datos_2020_graph$average_speed, 
                     main = "Velocidad media de los viajes 2020",
                     xlab = "KM/H",
                     ylab = "Frecuencia",
                     ylim = c(0,350000),
                     xlim = c(0,18),
                     xaxt = "n",
                     yaxt = "n",
                     col = 'lightgreen',  
                     border = "black",   
                     breaks = 30) 

axis(1, at = seq(0, 18, by = 2))
axis(2, at = seq(0, 350000, by = 50000), labels = format(seq(0, 350000, by = 50000), format = "e", digits = 1))

# 2022

histogram3_22<- hist(datos_2022_graph$average_speed, 
                     main = "Velocidad media de los viajes 2022",
                     xlab = "KM/H",
                     ylab = "Frecuencia",
                     ylim = c(0,350000),
                     xaxt = "n",
                     yaxt = "n",
                     col = "lightpink", 
                     border = "black",   
                     breaks = 30) 

axis(1, at = seq(0, 18, by = 2))
axis(2, at = seq(0, 350000, by = 50000), labels = format(seq(0, 350000, by = 50000), format = "e", digits = 1))


# 3.1.8 Histograma de la edad de cada usuario 2019/2020

fecha_actual <- Sys.Date()
edad19 <- as.numeric(format(fecha_actual, "%Y")) - datos_2019_graph$birth_year
edad20 <- as.numeric(format(fecha_actual, "%Y")) - datos_2020_graph$birth_year

  
#2019  
histogram4_19<- hist(edad19, 
                     main = "Edad de los usuarios de 2019",
                     xlab = "Kilómetros del viaje",
                     ylab = "Frecuencia",
                     col = "lightblue",
                     xlim = c(20, 70),
                     ylim = c(0, 400000),
                     yaxt = "n",
                     border = "black",   
                     breaks = 20) 

axis(2, at = seq(0, 400000, by = 50000), labels = format(seq(0, 400000, by = 50000), format = "e", digits = 1))

#2020
histogram4_19<- hist(edad20, 
                     main = "Edad de los usuarios de 2020",
                     xlab = "Kilómetros del viaje",
                     ylab = "Frecuencia",
                     col = "lightgreen", 
                     xlim = c(20, 70),
                     ylim = c(0, 400000),
                     yaxt = "n",
                     border = "black",   
                     breaks = 20) 

axis(2, at = seq(0, 400000, by = 50000), labels = format(seq(0, 400000, by = 50000), format = "e", digits = 1))


# 3.1.9 Usertype de cada año

#2019
usertype_counts <- table(datos_2019_graph$usertype)
barplot(usertype_counts,
        col = c('lightblue', 'lightblue'),
        main = 'Tipo de usuario 2019',
        xlab = 'User Type',
        ylab = 'Frecuencia',
        yaxt = "n",
        ylim = c(0,4000000))

axis(2, at = seq(0, 4000000, by = 500000), labels = format(seq(0, 4000000, by = 500000), format = "e", digits = 1))

#2020
usertype_counts <- table(datos_2020_graph$usertype)
barplot(usertype_counts,
        col = c('lightgreen', 'lightgreen'),
        main = 'Tipo de usuario 2020',
        xlab = 'User Type',
        ylab = 'Frecuencia',
        ylim = c(0, 4000000),
        yaxt = "n")

axis(2, at = seq(0, 4000000, by = 500000), labels = format(seq(0, 4000000, by = 500000), format = "e", digits = 1))

#2022
usertype_counts <- table(datos_2022_graph$usertype)
barplot(usertype_counts,
        col = c('lightpink', 'lightpink'),
        main = 'Tipo de usuario 2022',
        xlab = 'User Type',
        ylab = 'Frecuencia',
        ylim = c(0, 4000000),
        yaxt = "n")

axis(2, at = seq(0, 4000000, by = 500000), labels = format(seq(0, 4000000, by = 500000), format = "e", digits = 1))

# 3.1.10 Tipo de bicicletas usadas en 2022

biketype_counts <- table(datos_2022_graph$rideable_type)
barplot(biketype_counts, col = "lightblue", main = 'Tipo de bicicleta usada en 2022', xlab = 'Bike Type', ylab = 'Frecuencia')

proporcionA <- sum(datos_2022_graph$rideable_type == "classic_bike")/nrow(datos_2022_graph)
proporcionB <- sum(datos_2022_graph$rideable_type == "docked_bike")/nrow(datos_2022_graph)
proporcionC <- sum(datos_2022_graph$rideable_type == "electric_bike")/nrow(datos_2022_graph)


# 3.1.11 Estaciones donde se cogen más bicicletas

#2019
station_count <- table(datos_2019_graph$start_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,3)
barplot(station_count, col = 'lightblue', main = 'Estaciones donde se recogen más bicicletas 2019', xlab = 'Station Name', ylab = 'Frecuencia',cex.names = 0.8, ylim = c(0,25000))

#2020
station_count <- table(datos_2020_graph$start_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,3)
barplot(station_count, col = 'lightgreen', main = 'Estaciones donde se recogen más bicicletas 2020', xlab = 'Station Name', ylab = 'Frecuencia',cex.names = 0.8, ylim = c(0,25000))


#2022
station_count <- table(datos_2022_graph$start_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,3)
barplot(station_count, col = 'lightpink', main = 'Estaciones donde se recogen más bicicletas 2022', xlab = 'Station Name', ylab = 'Frecuencia',cex.names = 0.8, ylim = c(0,25000))


# 3.1.12 Estaciones donde se devuelven más bicicletas

#2019
station_count <- table(datos_2019_graph$end_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,3)
barplot(station_count, col = "lightblue", main = 'Estaciones donde se devuelven más bicicletas 2019', xlab = 'Station Name', ylab = 'Frecuencia',cex.names = 0.8)

#2020
station_count <- table(datos_2020_graph$end_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,3)
barplot(station_count, col = "lightgreen", main = 'Estaciones donde se devuelven más bicicletas 2020', xlab = 'Station Name', ylab = 'Frecuencia',cex.names = 0.8)

#2022
station_count <- table(datos_2022_graph$end_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,3)
barplot(station_count, col = "lightpink", main = 'Estaciones donde se devuelven más bicicletas 2022', xlab = 'Station Name', ylab = 'Frecuencia',cex.names = 0.8)


# 3.1.12 Uso de las bicicletas por ID 2019/2020

#2019
bikeid_count <- table(datos_2019_graph$bikeid)
bikeid_count <- bikeid_count[order(-bikeid_count)]
bikeid_count <- head(bikeid_count, 3)
barplot(bikeid_count, col = "lightblue", main = 'Bicicletas menos usadas en 2019', xlab = 'Bike ID', ylab = 'Frecuencia', cex.names = 0.8)

#2020
bikeid_count <- table(datos_2020_graph$bikeid)
bikeid_count <- bikeid_count[order(bikeid_count)]
bikeid_count <- head(bikeid_count, 3)
barplot(bikeid_count, col = "lightgreen", main = 'Bicicletas menos usadas en 2020', xlab = 'Bike ID', ylab = 'Frecuencia', cex.names = 0.8)


# 3.1.13 Histograma horas del dia

datos_2019_graph$hour <- as.integer(substr(datos_2019_graph$starttime, 12, 13))
datos_2020_graph$hour <- as.integer(substr(datos_2020_graph$starttime, 12, 13))
datos_2022_graph$hour <- as.integer(substr(datos_2022_graph$started_at, 12, 13))
datos_2022_graph$hour[is.na(datos_2022_graph$hour)] <- 0

categorias <- c("08-10", "11-13", "14-16", "17-19", "20-22")

#2019

viajes1_19 <- sum(datos_2019_graph$hour >= 08 & datos_2019_graph$hour <= 10)
viajes2_19 <- sum(datos_2019_graph$hour >= 11 & datos_2019_graph$hour <= 13)
viajes3_19 <- sum(datos_2019_graph$hour >= 14 & datos_2019_graph$hour <= 16)
viajes4_19 <- sum(datos_2019_graph$hour >= 17 & datos_2019_graph$hour <= 19)
viajes5_19 <- sum(datos_2019_graph$hour >= 20 & datos_2019_graph$hour <= 22)
frecuencia19 <- c(viajes1_19, viajes2_19, viajes3_19, viajes4_19, viajes5_19)

barplot(frecuencia19,
        names.arg = categorias,
        main = "Viajes por franja horaria 2019",
        xlab = "Categoría de Horas",
        ylab = "Frecuencia",
        col = "lightblue",
        ylim = c(0, 1500000),
        yaxt = "n")

axis(2, at = seq(0, 1500000, by = 500000), labels = format(seq(0, 1500000, by = 500000), format = "e", digits = 1))

#2020

viajes1_20 <- sum(datos_2020_graph$hour >= 08 & datos_2020_graph$hour <= 10)
viajes2_20 <- sum(datos_2020_graph$hour >= 11 & datos_2020_graph$hour <= 13)
viajes3_20 <- sum(datos_2020_graph$hour >= 14 & datos_2020_graph$hour <= 16)
viajes4_20 <- sum(datos_2020_graph$hour >= 17 & datos_2020_graph$hour <= 19)
viajes5_20 <- sum(datos_2020_graph$hour >= 20 & datos_2020_graph$hour <= 22)
frecuencia20 <- c(viajes1_20, viajes2_20, viajes3_20, viajes4_20, viajes5_20)

barplot(frecuencia20,
        names.arg = categorias,
        main = "Viajes por franja horaria 2019",
        xlab = "Categoría de Horas",
        ylab = "Frecuencia",
        col = "lightgreen",
        ylim = c(0, 1500000),
        yaxt = "n")

axis(2, at = seq(0, 1500000, by = 500000), labels = format(seq(0, 1500000, by = 500000), format = "e", digits = 1))

#2022

viajes1_22 <- sum(datos_2022_graph$hour >= 08 & datos_2022_graph$hour <= 10)
viajes2_22 <- sum(datos_2022_graph$hour >= 11 & datos_2022_graph$hour <= 13)
viajes3_22 <- sum(datos_2022_graph$hour >= 14 & datos_2022_graph$hour <= 16)
viajes4_22 <- sum(datos_2022_graph$hour >= 17 & datos_2022_graph$hour <= 19)
viajes5_22 <- sum(datos_2022_graph$hour >= 22 & datos_2022_graph$hour <= 22)
frecuencia22 <- c(viajes1_22, viajes2_22, viajes3_22, viajes4_22, viajes5_22)

barplot(frecuencia22,
        names.arg = categorias,
        main = "Viajes por franja horaria 2019",
        xlab = "Categoría de Horas",
        ylab = "Frecuencia",
        col = "lightpink",
        ylim = c(0, 1500000),
        yaxt = "n")

axis(2, at = seq(0, 1500000, by = 500000), labels = format(seq(0, 1500000, by = 500000), format = "e", digits = 1))

# 3.1.14 Histograma por dia de la semana por cada tipo de cliente

#customer

datos_2019_customer <- subset(datos_2019_graph, usertype == "Customer")
datos_2020_customer <- subset(datos_2020_graph, usertype == "Customer")
datos_2022_customer <- subset(datos_2022_graph, usertype == "customer")

#creamos la variable con el día de la semana de cada viaje

datos_2019_customer$dia <- weekdays(datos_2019_customer$starttime)
datos_2020_customer$dia <- weekdays(datos_2020_customer$starttime)
datos_2022_customer$dia <- weekdays(datos_2022_customer$started_at)

categorias2 <- c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday")

#2019

dia1_19 <- sum(datos_2019_customer$dia == "lunes")
dia2_19 <- sum(datos_2019_customer$dia == "martes")
dia3_19 <- sum(datos_2019_customer$dia == "miércoles")
dia4_19 <- sum(datos_2019_customer$dia == "jueves")
dia5_19 <- sum(datos_2019_customer$dia == "viernes")
dia6_19 <- sum(datos_2019_customer$dia == "sábado")
dia7_19 <- sum(datos_2019_customer$dia == "domingo")

frecuencia2_19 <- c(dia1_19, dia2_19, dia3_19, dia4_19, dia5_19, dia6_19, dia7_19)
barplot(frecuencia2_19,
        names.arg = categorias2,
        main = "Viajes por día de la semana 2019 (customer)",
        xlab = "Día de la semana",
        ylab = "Frecuencia",
        yaxt = "n",
        col = "lightblue",
        ylim = c(0, 200000),
        cex.names = 0.7)

axis(2, at = seq(0, 200000, by = 25000), labels = format(seq(0, 200000, by = 25000), format = "e", digits = 1))




#2020

dia1_20 <- sum(datos_2020_customer$dia == "lunes")
dia2_20 <- sum(datos_2020_customer$dia == "martes")
dia3_20 <- sum(datos_2020_customer$dia == "miércoles")
dia4_20 <- sum(datos_2020_customer$dia == "jueves")
dia5_20 <- sum(datos_2020_customer$dia == "viernes")
dia6_20 <- sum(datos_2020_customer$dia == "sábado")
dia7_20 <- sum(datos_2020_customer$dia == "domingo")

frecuencia2_20 <- c(dia1_20, dia2_20, dia3_20, dia4_20, dia5_20, dia6_20, dia7_20)
barplot(frecuencia2_20,
        names.arg = categorias2,
        main = "Viajes por día de la semana 2020 (customer)",
        xlab = "Día de la semana",
        ylab = "Frecuencia",
        yaxt = "n",
        col = "lightgreen",
        ylim = c(0, 200000),
        cex.names = 0.7)

axis(2, at = seq(0, 200000, by = 25000), labels = format(seq(0, 200000, by = 25000), format = "e", digits = 1))

#2022

dia1_22 <- sum(datos_2022_customer$dia == "lunes")
dia2_22 <- sum(datos_2022_customer$dia == "martes")
dia3_22 <- sum(datos_2022_customer$dia == "miércoles")
dia4_22 <- sum(datos_2022_customer$dia == "jueves")
dia5_22 <- sum(datos_2022_customer$dia == "viernes")
dia6_22 <- sum(datos_2022_customer$dia == "sábado")
dia7_22 <- sum(datos_2022_customer$dia == "domingo")

frecuencia2_22 <- c(dia1_22, dia2_22, dia3_22, dia4_22, dia5_22, dia6_22, dia7_22)
barplot(frecuencia2_22,
        names.arg = categorias2,
        main = "Viajes por día de la semana 2022 (customer)",
        xlab = "Día de la semana",
        ylab = "Frecuencia",
        yaxt = "n",
        col = "lightpink",
        ylim = c(0, 200000),
        cex.names = 0.7)

axis(2, at = seq(0, 200000, by = 25000), labels = format(seq(0, 200000, by = 25000), format = "e", digits = 1))


#subscriber

datos_2019_subscriber <- subset(datos_2019_graph, usertype == "Subscriber")
datos_2020_subscriber <- subset(datos_2020_graph, usertype == "Subscriber")
datos_2022_subscriber <- subset(datos_2022_graph, usertype == "Suscriber")

#creamos la variable con el día de la semana de cada viaje

datos_2019_subscriber$dia <- weekdays(datos_2019_subscriber$starttime)
datos_2020_subscriber$dia <- weekdays(datos_2020_subscriber$starttime)
datos_2022_subscriber$dia <- weekdays(datos_2022_subscriber$started_at)

categorias2 <- c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday")

#2019

dia1_19 <- sum(datos_2019_subscriber$dia == "lunes")
dia2_19 <- sum(datos_2019_subscriber$dia == "martes")
dia3_19 <- sum(datos_2019_subscriber$dia == "miércoles")
dia4_19 <- sum(datos_2019_subscriber$dia == "jueves")
dia5_19 <- sum(datos_2019_subscriber$dia == "viernes")
dia6_19 <- sum(datos_2019_subscriber$dia == "sábado")
dia7_19 <- sum(datos_2019_subscriber$dia == "domingo")

frecuencia2_19 <- c(dia1_19, dia2_19, dia3_19, dia4_19, dia5_19, dia6_19, dia7_19)
barplot(frecuencia2_19,
        names.arg = categorias2,
        main = "Viajes por día de la semana 2019 (subscriber)",
        xlab = "Día de la semana",
        ylab = "Frecuencia",
        yaxt = "n",
        col = "lightblue",
        ylim = c(0, 1000000),
        cex.names = 0.7)

axis(2, at = seq(0, 1000000, by = 250000), labels = format(seq(0, 1000000, by = 250000), format = "e", digits = 1))

#2020

dia1_20 <- sum(datos_2020_subscriber$dia == "lunes")
dia2_20 <- sum(datos_2020_subscriber$dia == "martes")
dia3_20 <- sum(datos_2020_subscriber$dia == "miércoles")
dia4_20 <- sum(datos_2020_subscriber$dia == "jueves")
dia5_20 <- sum(datos_2020_subscriber$dia == "viernes")
dia6_20 <- sum(datos_2020_subscriber$dia == "sábado")
dia7_20 <- sum(datos_2020_subscriber$dia == "domingo")

frecuencia2_20 <- c(dia1_20, dia2_20, dia3_20, dia4_20, dia5_20, dia6_20, dia7_20)
barplot(frecuencia2_20,
        names.arg = categorias2,
        main = "Viajes por día de la semana 2020 (subscriber)",
        xlab = "Día de la semana",
        ylab = "Frecuencia",
        yaxt = "n",
        col = "lightgreen",
        ylim = c(0, 1000000),
        cex.names = 0.7)

axis(2, at = seq(0, 1000000, by = 250000), labels = format(seq(0, 1000000, by = 250000), format = "e", digits = 1))

#2022

dia1_22 <- sum(datos_2022_subscriber$dia == "lunes")
dia2_22 <- sum(datos_2022_subscriber$dia == "martes")
dia3_22 <- sum(datos_2022_subscriber$dia == "miércoles")
dia4_22 <- sum(datos_2022_subscriber$dia == "jueves")
dia5_22 <- sum(datos_2022_subscriber$dia == "viernes")
dia6_22 <- sum(datos_2022_subscriber$dia == "sábado")
dia7_22 <- sum(datos_2022_subscriber$dia == "domingo")

frecuencia2_22 <- c(dia1_22, dia2_22, dia3_22, dia4_22, dia5_22, dia6_22, dia7_22)
barplot(frecuencia2_22,
        names.arg = categorias2,
        main = "Viajes por día de la semana 2022 (susbscriber)",
        xlab = "Día de la semana",
        ylab = "Frecuencia",
        yaxt = "n",
        col = "lightpink",
        ylim = c(0, 1000000),
        cex.names = 0.7)

axis(2, at = seq(0, 1000000, by = 250000), labels = format(seq(0, 1000000, by = 250000), format = "e", digits = 1))


# 3.1.15 Histograma por mes

datos_2019_graph$mes <- format(datos_2019_graph$starttime, "%B")
datos_2020_graph$mes <- format(datos_2020_graph$starttime, "%B")
datos_2022_graph$mes <- format(datos_2022_graph$started_at, "%B")


categorias3 <- c("jan", "feb", "march", "april", "may", "june", "july", "aug", "sept", "oct", "nov", "dec")

#2019

mes1_19 <- sum(datos_2019_graph$mes == "enero")
mes2_19 <- sum(datos_2019_graph$mes == "febrero")
mes3_19 <- sum(datos_2019_graph$mes == "marzo")
mes4_19 <- sum(datos_2019_graph$mes == "abril")
mes5_19 <- sum(datos_2019_graph$mes == "mayo")
mes6_19 <- sum(datos_2019_graph$mes == "junio")
mes7_19 <- sum(datos_2019_graph$mes == "julio")
mes8_19 <- sum(datos_2019_graph$mes == "agosto")
mes9_19 <- sum(datos_2019_graph$mes == "septiembre")
mes10_19 <- sum(datos_2019_graph$mes == "octubre")
mes11_19 <- sum(datos_2019_graph$mes == "noviembre")
mes12_19 <- sum(datos_2019_graph$mes == "diciembre")
frecuencia3_19 <- c(mes1_19, mes2_19, mes3_19, mes4_19, mes5_19, mes6_19, mes7_19, mes8_19, mes9_19, mes10_19,
                    mes11_19, mes12_19)

barplot(frecuencia3_19,
        names.arg = categorias3,
        main = "Viajes por mes 2019",
        xlab = "Mes",
        ylab = "Frecuencia",
        col = "lightblue",
        ylim = c(0, 650000),
        las = 0,
        cex.names = 0.7)



#2020

mes1_20 <- sum(datos_2020_graph$mes == "enero")
mes2_20 <- sum(datos_2020_graph$mes == "febrero")
mes3_20 <- sum(datos_2020_graph$mes == "marzo")
mes4_20 <- sum(datos_2020_graph$mes == "abril")
mes5_20 <- sum(datos_2020_graph$mes == "mayo")
mes6_20 <- sum(datos_2020_graph$mes == "junio")
mes7_20 <- sum(datos_2020_graph$mes == "julio")
mes8_20 <- sum(datos_2020_graph$mes == "agosto")
mes9_20 <- sum(datos_2020_graph$mes == "septiembre")
mes10_20 <- sum(datos_2020_graph$mes == "octubre")
mes11_20 <- sum(datos_2020_graph$mes == "noviembre")
mes12_20 <- sum(datos_2020_graph$mes == "diciembre")
frecuencia3_20 <- c(mes1_20, mes2_20, mes3_20, mes4_20, mes5_20, mes6_20, mes7_20, mes8_20, mes9_20, mes10_20,
                    mes11_20, mes12_20)

barplot(frecuencia3_20,
        names.arg = categorias3,
        main = "Viajes por mes 2020",
        xlab = "Mes",
        ylab = "Frecuencia",
        col = "lightgreen",
        ylim = c(0, 650000),
        las = 0,
        cex.names = 0.7)



#2022

mes1_22 <- sum(datos_2022_graph$mes == "enero")
mes2_22 <- sum(datos_2022_graph$mes == "febrero")
mes3_22 <- sum(datos_2022_graph$mes == "marzo")
mes4_22 <- sum(datos_2022_graph$mes == "abril")
mes5_22 <- sum(datos_2022_graph$mes == "mayo")
mes6_22 <- sum(datos_2022_graph$mes == "junio")
mes7_22 <- sum(datos_2022_graph$mes == "julio")
mes8_22 <- sum(datos_2022_graph$mes == "agosto")
mes9_22 <- sum(datos_2022_graph$mes == "septiembre")
mes10_22 <- sum(datos_2022_graph$mes == "octubre")
mes11_22 <- sum(datos_2022_graph$mes == "noviembre")
mes12_22 <- sum(datos_2022_graph$mes == "diciembre")
frecuencia3_22 <- c(mes1_22, mes2_22, mes3_22, mes4_22, mes5_22, mes6_22, mes7_22, mes8_22, mes9_22, mes10_22,
                    mes11_22, mes12_22)

barplot(frecuencia3_22,
        names.arg = categorias3,
        main = "Viajes por mes 2022",
        xlab = "Mes",
        ylab = "Frecuencia",
        col = "lightpink",
        ylim = c(0, 650000),
        las = 0,
        cex.names = 0.7)

proporcion_prueba <- sum(mes1_22, mes2_22)/sum(mes1_19, mes2_19) -1

# ============================================================================================#




# ========================= 4. IMPORTAMOS EL DATASET DE LOS ZIPCODES ============================

valores_zip_unicos19 <- unique(datos_2019_vf$start_zip)
valores_zip_unicos20 <- unique(datos_2020_vf$start_zip)
valores_zip_unicos22 <- unique(datos_2022_vf$start_zip)

zips_unicos <- sort(unique(c(valores_zip_unicos19, valores_zip_unicos20, valores_zip_unicos22)))

# Cambiamos directorio a donde se encuentra el dataset

setwd("C:/Users/alfre/OneDrive - Universidad Pontificia Comillas/Ordenador ACER/5º Carrera/TFG/TFG Business Analytics/R Studio")

# Cargamos el dataset

zipcodes <-  read_xlsx("ZipsNY.xlsx")


# Insepeccionamos las variables

str(zipcodes)
summary(zipcodes)
sapply(zipcodes, class)


# Creamos los diagramas de violín de las variables sociodemográficas

# Commute Time to Work

vioplot(zipcodes$commute_time_to_work,
        names = "Commute Time to Work",
        col = "#FFCC9E",
        ylab = "Minutes")


# Poverty

vioplot(zipcodes$Poverty,
        names = "Poverty",
        col = "#FFCC9E",
        ylab = "% Poverty")


# Añadimos al dataset una nueva columna con los viaje realizados en 2022

count_zips_22 <- datos_2022_graph %>% group_by(start_zip) %>% tally(name = "trips_2022")

zipcodes <- zipcodes %>% left_join(count_zips_22, by = c("zipcode" = "start_zip"))

zipcodes <- na.omit(zipcodes)

summary(zipcodes)

# Extraemos las correlaciones de los viajes y las variables sociodemográficas

variables_interes <- zipcodes[, c("population", "commute_time_to_work", "no_healthcare_insurance", "trips_2022")]

variables_interes_scale <- as.data.frame(scale(variables_interes, scale = TRUE, center = TRUE))

correlacion <- round(cor(variables_interes_scale), 3)

# Creamos el modelo de regresión lineal múltiple

modelo <- lm(trips_2022 ~. , data = variables_interes)

summary(modelo)


vif_values <- vif(modelo)
print(vif_values)


# Descarga del dataset final que vamos a utilizar para Power BI

#Descarga de dataset final para Power BI

# 2019

tamaño_fragmento <- 500000

n_filas <- nrow(datos_2019_graph)

n_archivos <- ceiling(n_filas / tamaño_fragmento)


for (i in 1:n_archivos) {
  inicio <- (i - 1) * tamaño_fragmento + 1
  fin <- min(i * tamaño_fragmento, n_filas)
  fragmento <- datos_2019_graph[inicio:fin, ]
  nombre_archivo <- paste0("datos_2019_graph_parte_", i, ".feather")
  write_feather(fragmento, nombre_archivo)
}

# 2020

tamaño_fragmento <- 500000

n_filas <- nrow(datos_2020_graph)

n_archivos <- ceiling(n_filas / tamaño_fragmento)


for (i in 1:n_archivos) {
  inicio <- (i - 1) * tamaño_fragmento + 1
  fin <- min(i * tamaño_fragmento, n_filas)
  fragmento <- datos_2020_graph[inicio:fin, ]
  nombre_archivo <- paste0("datos_2020_graph_parte_", i, ".feather")
  write_feather(fragmento, nombre_archivo)
}

# 2022

tamaño_fragmento <- 500000

n_filas <- nrow(datos_2022_graph)

n_archivos <- ceiling(n_filas / tamaño_fragmento)


for (i in 1:n_archivos) {
  inicio <- (i - 1) * tamaño_fragmento + 1
  fin <- min(i * tamaño_fragmento, n_filas)
  fragmento <- datos_2022_graph[inicio:fin, ]
  nombre_archivo <- paste0("datos_2022_graph_parte_", i, ".feather")
  write_feather(fragmento, nombre_archivo)
}


#-------------------------------------------------------------------------------------------#

 