
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

library(readxl)
library(dplyr)
library(readr)
library(ggmap)
library(ggcorrplot)
library(corrplot)
library(leaflet)
library(cluster)
library(factoextra)

# Establecemos directorio

setwd("C:/Users/alfre/OneDrive/Documentos/5º Carrera/TFG/TFG Business Analytics/R Studio/Final_Data")

# Importamos nuestros datasets desde el directorio

data_2019 <- read_csv("datos_2019_vf.csv")
data_2020 <- read_csv("datos_2020_vf.csv")
data_2022 <- read_csv("datos_2022_vf.csv")

# Omitimos los valores nulos (NA)

datos_2019 <- na.omit(data_2019)
datos_2020 <- na.omit(data_2020)
datos_2022 <- na.omit(data_2022)

# Número de NAs borrados de cada dataset

Nas2019 <- sum(is.na(data_2019)) - sum(is.na(na.omit(data_2019)))
Nas2020 <- sum(is.na(data_2020)) - sum(is.na(na.omit(data_2020)))
Nas2022 <- sum(is.na(data_2022)) - sum(is.na(na.omit(data_2022)))

cat("El número de NAs de 2019 es", Nas2019, ", el de 2020 es", Nas2020, "y el de 2022 es", Nas2022)

# Sustituimos los espacios del nombre de las variables por "_"

new_colnames_2019 <- gsub(" ", "_", colnames(datos_2019))
colnames(datos_2019) <- new_colnames_2019

new_colnames_2020 <- gsub(" ", "_", colnames(datos_2020))
colnames(datos_2020) <- new_colnames_2020

new_colnames_2022 <- gsub(" ", "_", colnames(datos_2022))
colnames(datos_2022) <- new_colnames_2022

# ========================== TRATAMIENTO DE LOS DATOS ==================================

# 1. Estructura de las varibles

# Datos_2019

str(datos_2019)
summary(datos_2019)
sapply(datos_2019, class)

# Datos_2020

str(datos_2020)
summary(datos_2020)
sapply(datos_2020, class)

# Datos_2022

str(datos_2022)
summary(datos_2022)
sapply(datos_2022, class)

# ===================== Comparación de las variables de los datasets =======================

new_colnames_2019 # variables de 2019
new_colnames_2020 # variables de 2020
new_colnames_2022 # variables de 2022

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

  # Las variables de 2019 y 2020 son las mismas. 
  # Sin embargo, en 2022 faltan variables como "tripduration", "bikeid" y "birth_year"

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Estandarizamos las variables "user_type" y "member_casual en los datos de 2022"

datos_2022$usertype = ifelse(datos_2022$member_casual == "member", "suscriber",
                            ifelse(datos_2022$member_casual == "casual", "customer",
                                   datos_2022$member_casual))

# Eliminamos la variable original (member_casual)

datos_2022 <- subset(datos_2022, select = -member_casual)


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    # Observamos como la variable "tripduration" es negativa. Procedemos a examinar las observaciones con duración negativas

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

subset_datos2022 <- subset(datos_2022, tripduration<0)


ids_to_delete_2022 <-subset_datos2022[1:4]

#Hay una fecha en la que se producen muchas tripdurations negativas. Es en 2022-11-06. Tras analizar esta fecha, he podido ver que en ese día se cambia la hora en Nueva York, por lo tanto, voy a sumar 1 hora (3600 segundos) a cada Tripduration
# El resto de fechas las borramos ya que no se puede explicar porque tienen duración negativa


datos_2022[datos_2022$ride_id %in% subset_datos2022$ride_id, ]$tripduration <- subset_datos2022$tripduration + 3600

datos_2022 <- subset(datos_2022, !(ride_id %in% ids_to_delete_2022))

  
# =========== Eliminamos las variables de tipo caracter de nuestro dataset =================

# 2019
character_variable_2019 <- c("start_station_name", "end_station_name", "usertype", "bikeid", "gender", "start_zip", "end_zip", "start_city", "end_city")  # Lista de variables a eliminar
datos_2019_numeric <- datos_2019 %>% select(-one_of(character_variable_2019))

# 2020
character_variable_2020 <- c("start_station_name", "end_station_name", "usertype", "bikeid", "gender", "start_zip", "end_zip", "start_city", "end_city")  # Lista de variables a eliminar
datos_2020_numeric <- datos_2020 %>% select(-one_of(character_variable_2020))

# 2022
character_variable_2022 <- c("ride_id","rideable_type", "start_station_id","start_station_name", "end_station_id", "end_station_name", "usertype", "start_zip", "end_zip", "start_city", "end_city")  # Lista de variables a eliminar
datos_2022_numeric <- datos_2022 %>% select(-one_of(character_variable_2022))


# ========================== Exploración de los datos ==========================

# Identificación de outliers(código para descargarse los boxplots a archivos png)

output_directory_2019 <- "C:\\Users\\alfre\\OneDrive\\Documentos\\5º Carrera\\TFG\\TFG Business Analytics\\R Studio\\Imagenes_R\\2019\\"
output_directory_2020 <- "C:\\Users\\alfre\\OneDrive\\Documentos\\5º Carrera\\TFG\\TFG Business Analytics\\R Studio\\Imagenes_R\\2020\\"
output_directory_2022 <- "C:\\Users\\alfre\\OneDrive\\Documentos\\5º Carrera\\TFG\\TFG Business Analytics\\R Studio\\Imagenes_R\\2022\\"

# 2019

for (col_name in names(datos_2019_numeric)) {

  png_file <- paste0(output_directory_2019, col_name, " 2019_boxplot.png")
  png(png_file, width = 800, height = 600)
  
  boxplot(datos_2019_numeric[col_name], main = col_name)
  
  dev.off()  # Cierra el archivo PNG
  
  cat("Boxplot para", col_name, "guardado en", png_file, "\n")
}
summary(datos_2019_numeric)
# 2020

for (col_name in names(datos_2020_numeric)) {
  
  png_file <- paste0(output_directory_2020, col_name, " 2020_boxplot.png")
  png(png_file, width = 800, height = 600)
  
  boxplot(datos_2020_numeric[col_name], main = col_name)
  
  dev.off()  # Cierra el archivo PNG
  
  cat("Boxplot para", col_name, "guardado en", png_file, "\n")
}

# 2022

for (col_name in names(datos_2022_numeric)) {
  
  png_file <- paste0(output_directory_2022, col_name, " 2022_boxplot.png")
  png(png_file, width = 800, height = 600)
  
  boxplot(datos_2022_numeric[col_name], main = col_name)
  
  dev.off()  # Cierra el archivo PNG
  
  cat("Boxplot para", col_name, "guardado en", png_file, "\n")
}



# ================ TRATAMIENTO DE OUTLIERS (SUSTITUYÉNDOLOS POR LA MEDIA DE SU VARIABLE) ================

# Variables en la que tiene sentido identificar y modificar outliers

# 2019
outlier_variable_2019 <- c("tripduration", "birth_year","distance_km", "average_speed")
datos_2019_outliers <- datos_2019 %>% select(one_of(outlier_variable_2019))

head(datos_2019_outliers, 50)
# 2020
outlier_variable_2020 <- c("tripduration", "birth_year","distance_km","average_speed")
datos_2020_outliers <- datos_2020 %>% select(one_of(outlier_variable_2020))

# 2022
outlier_variable_2022 <- c("tripduration","distance_km","average_speed")
datos_2022_outliers <- datos_2022 %>% select(one_of(outlier_variable_2022))

# Ajustamos outliers del dataset de 2019

num_cols19<- names(Filter(is.numeric, datos_2019_outliers)) #identificamos variables númericas
num_cols_ind19<- which(names(datos_2019_outliers) %in% c(num_cols19)) #identificamos índice de dichas variables

for (i in c(num_cols_ind19)){ #recorremos con un bucle las variables numéricas
  
  upper_limit19<-quantile(datos_2019_outliers[[i]],probs = 0.75)+(1.5*(IQR(datos_2019_outliers[[i]]))) #definimos limite superior
  lower_limit19<-quantile(datos_2019_outliers[[i]],probs = 0.25)-(1.5*(IQR(datos_2019_outliers[[i]]))) #definimos limite inferior
  
  datos_2019_outliers[[i]][datos_2019_outliers[[i]]>upper_limit19]<- NA #imputamos límite superior si el valor es superior al criterio
  datos_2019_outliers[[i]][datos_2019_outliers[[i]]<lower_limit19]<- NA #imputmaos límite inferior si el valor es inferior al criterio
}

# Ajustamos outliers del dataset de 2020

num_cols20<- names(Filter(is.numeric, datos_2020_outliers)) #identificamos variables númericas
num_cols_ind20<- which(names(datos_2020_outliers) %in% c(num_cols20)) #identificamos índice de dichas variables

for (i in c(num_cols_ind20)){ #recorremos con un bucle las variables numéricas
  
  upper_limit20<-quantile(datos_2020_outliers[[i]],probs = 0.75)+(1.5*(IQR(datos_2020_outliers[[i]]))) #definimos limite superior
  lower_limit20<-quantile(datos_2020_outliers[[i]],probs = 0.25)-(1.5*(IQR(datos_2020_outliers[[i]]))) #definimos limite inferior
  
  datos_2020_outliers[[i]][datos_2020_outliers[[i]]>upper_limit20]<- upper_limit20 #imputamos límite superior si el valor es superior al criterio
  datos_2020_outliers[[i]][datos_2020_outliers[[i]]<lower_limit20]<- lower_limit20 #imputmaos límite inferior si el valor es inferior al criterio
}

# Ajustamos outliers del dataset de 2022

num_cols22<- names(Filter(is.numeric, datos_2022_outliers)) #identificamos variables númericas
num_cols_ind22<- which(names(datos_2022_outliers) %in% c(num_cols22)) #identificamos índice de dichas variables

for (i in c(num_cols_ind22)){ #recorremos con un bucle las variables numéricas
  
  upper_limit22<-quantile(datos_2022_outliers[[i]],probs = 0.75)+(1.5*(IQR(datos_2022_outliers[[i]]))) #definimos limite superior
  lower_limit22<-quantile(datos_2022_outliers[[i]],probs = 0.25)-(1.5*(IQR(datos_2022_outliers[[i]]))) #definimos limite inferior
  
  datos_2022_outliers[[i]][datos_2022_outliers[[i]]>upper_limit22]<- upper_limit22 #imputamos límite superior si el valor es superior al criterio
  datos_2022_outliers[[i]][datos_2022_outliers[[i]]<lower_limit22]<- lower_limit22 #imputmaos límite inferior si el valor es inferior al criterio
}

# ============================== CREACIÓN DEL DATASET FINAL =======================================

# 2019

datos_2019_vf <- datos_2019 %>% select(-one_of(outlier_variable_2019))
datos_2019_vf <- cbind(datos_2019_outliers, datos_2019_vf)

# 2020

datos_2020_vf <- datos_2020 %>% select(-one_of(outlier_variable_2020))
datos_2020_vf <- cbind(datos_2020_outliers, datos_2020_vf)

# 2022

datos_2022_vf <- datos_2022 %>% select(-one_of(outlier_variable_2022))
datos_2022_vf <- cbind(datos_2022_outliers, datos_2022_vf)

# =============== EVOLUCIÓN EN EL USO DE LAS BICIS DESPUÉS DE LA PANDEMIA ==========================

# ================================ GRÁFICOS DE CADA DATASET ========================================


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

c <- datos_2020_outliers$tripduration - colMeans(datos_2020_outliers[1])

datos_2020_graph <- datos_2020 %>% select(-one_of(outlier_variable_2020))
datos_2020_graph <- na.omit(cbind(datos_2020_outliers, datos_2020_graph))
summary(datos_2020_graph)
# 2022

for (variable_name in names(datos_2022_outliers)) {
  
  variable_estandarizada_22 <- scale(datos_2022_outliers[[variable_name]])
  condicion_22 <- abs(variable_estandarizada_22) <= num_desviaciones_std
  datos_2022_outliers[[variable_name]][!condicion_22] <- NA
}


datos_2022_graph <- datos_2022 %>% select(-one_of(outlier_variable_2022))
datos_2022_graph <- na.omit(cbind(datos_2022_outliers, datos_2022_graph))



# Estandarizamos los datos

datos_scale19 <- Filter(is.numeric, datos_2019_graph)
datos_scale19 <- as.data.frame(scale(datos_scale19, scale = TRUE, center = TRUE))

datos_scale20 <- Filter(is.numeric, datos_2020_graph)
datos_scale20 <- as.data.frame(scale(datos_scale20, scale = TRUE, center = TRUE))

datos_scale22 <- Filter(is.numeric, datos_2022_graph)
datos_scale22 <- as.data.frame(scale(datos_scale22, scale = TRUE, center = TRUE))


# Matriz de correlaciones

# 2019

corr19<- round(cor(datos_scale19),3)
as.matrix(corr19, rownames=NULL)
corrplot(corr19, method="color", type="upper",tl.cex = 0.5, tl.col = 'black')

# 2020

corr20<- round(cor(datos_scale20),3)
as.matrix(corr20, rownames=NULL)
corrplot(corr20, method="color", type="upper",tl.cex = 0.5, tl.col = 'black')

# 2022

corr22<- round(cor(datos_scale22),3)
as.matrix(corr22, rownames=NULL)
corrplot(corr22, method="color", type="upper",tl.cex = 0.5, tl.col = 'black')

# =====================================================================================#

# Histograma de la duracion de cada viaje

# 2019

histogram1_19<- hist(datos_2019_graph$tripduration, 
                   main = "Histograma de la duración de los viajes 2019",
                   xlab = "Duración del viaje (segundos)",
                   ylab = "Frecuencia",
                   col = "lightblue",  
                   border = "black",  
                   breaks = 20) 

# 2020

histogram1_20<- hist(datos_2020_graph$tripduration, 
                   main = "Histograma de la duración de los viajes 2020",
                   xlab = "Duración del viaje (segundos)",
                   ylab = "Frecuencia",
                   col = "lightblue",  
                   border = "black",   
                   breaks = 20) 

# 2022

histogram1_22<- hist(datos_2022_graph$tripduration, 
                   main = "Histograma de la duración de los viajes 2022",
                   xlab = "Duración del viaje (segundos)",
                   ylab = "Frecuencia",
                   col = "lightblue", 
                   border = "black",   
                   breaks = 20) 

# Histograma de los kilómetros de cada viaje

# 2019

histogram2_19<- hist(datos_2019_graph$distance_km, 
                   main = "Histograma la distancia de los viajes 2019",
                   xlab = "Kilómetros del viaje",
                   ylab = "Frecuencia",
                   col = "orange",  
                   border = "black",  
                   breaks = 20) 

# 2020

histogram2_20<- hist(datos_2020_graph$distance_km, 
                   main = "Histograma la distancia de los viajes 2020",
                   xlab = "Kilómetros del viaje",
                   ylab = "Frecuencia",
                   col = "orange",  
                   border = "black",   
                   breaks = 20) 

# 2022

histogram2_22<- hist(datos_2022_graph$distance_km, 
                   main = "Histograma la distancia de los viajes 2022",
                   xlab = "Kilómetros del viaje",
                   ylab = "Frecuencia",
                   col = "orange", 
                   border = "black",   
                   breaks = 20) 


# Uso de las bicilcletas hombre y mujer

#2019

gender_counts <- table(datos_2019_graph$gender)
barplot(gender_counts, col = c('grey','blue', 'pink'), main = 'Uso de las bicicletas por género 2019', xlab = 'Género', ylab = 'Frecuencia', names.arg = c('Unknown','Male', 'Female'))

#2020

gender_counts <- table(datos_2020_graph$gender)
barplot(gender_counts, col = c('grey','blue', 'pink'), main = 'Uso de las bicicletas por género 2020', xlab = 'Género', ylab = 'Frecuencia', names.arg = c('Unknown','Male', 'Female'))

#En 2022 no tenemos la variable género (protección de datos)

# ZipCodes en los que se han cogido más bicis

#2019
zip_counts <- table(datos_2019_graph$start_zip)
zip_counts <- zip_counts[order(-zip_counts)]
barplot(zip_counts, col = c('red', 'grey'), main = 'ZipCodes de donde se recogen más bicis 2019', xlab = 'Start Zip Codes', ylab = 'Frecuencia')

#2020
zip_counts <- table(datos_2020_graph$start_zip)
zip_counts <- zip_counts[order(-zip_counts)]
barplot(zip_counts, col = c('red', 'grey'), main = 'ZipCodes de donde se recogen más bicis 2020', xlab = 'Start Zip Codes', ylab = 'Frecuencia')

#2022

zip_counts <- table(datos_2022_graph$start_zip)
zip_counts <- zip_counts[order(-zip_counts)]
barplot(zip_counts, col = c('red', 'grey'), main = 'ZipCodes de donde se recogen más bicis 2022', xlab = 'Start Zip Codes', ylab = 'Frecuencia')

# ZipCodes donde se han dejado más bicis

#2019
zip_counts <- table(datos_2019_graph$end_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,5)
barplot(zip_counts, col = c('yellow', 'grey'), main = 'ZipCodes de donde se dejan más bicis 2019', xlab = 'End Zip Codes', ylab = 'Frecuencia')

#2020
zip_counts <- table(datos_2020_graph$end_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,5)
barplot(zip_counts, col = c('yellow', 'grey'), main = 'ZipCodes de donde se dejan más bicis 2020', xlab = 'End Zip Codes', ylab = 'Frecuencia')

#2022

zip_counts <- table(datos_2022_graph$end_zip)
zip_counts <- zip_counts[order(-zip_counts)]
zip_counts <- head(zip_counts,5)
barplot(zip_counts, col = c('yellow', 'grey'), main = 'ZipCodes de donde se dejan más bicis 2022', xlab = 'End Zip Codes', ylab = 'Frecuencia')

# Ciudad en la que se utilizan más las bicis

#2019
star_city_count <- table(datos_2019_graph$start_city)

#2020
star_city_count <- table(datos_2020_graph$start_city)

#2022
star_city_count <- table(datos_2022_graph$start_city)

# Devolución de bicis

#2019
end_city_count <- table(datos_2019_graph$end_city)

#2020
star_city_count <- table(datos_2020_graph$start_city)

#2022
end_city_count <- table(datos_2022_graph$end_city)

# Histograma de la velocidad media de los viajes

histogram3_19<- hist(datos_2019_graph$average_speed, 
                     main = "Histograma de la distancia de los viajes 2019",
                     xlab = "Kilómetros del viaje",
                     ylab = "Frecuencia",
                     col = "orange",  
                     border = "black",  
                     breaks = 20) 

# 2020

histogram3_20<- hist(datos_2020_graph$average_speed, 
                     main = "Histograma de la distancia de los viajes 2020",
                     xlab = "Kilómetros del viaje",
                     ylab = "Frecuencia",
                     col = "orange",  
                     border = "black",   
                     breaks = 20) 

# 2022

histogram3_22<- hist(datos_2022_graph$average_speed, 
                     main = "Histograma de la distancia de los viajes 2022",
                     xlab = "Kilómetros del viaje",
                     ylab = "Frecuencia",
                     col = "orange", 
                     border = "black",   
                     breaks = 20) 

# Histograma de la edad de cada usuario 2019/2020

fecha_actual <- Sys.Date()
edad19 <- as.numeric(format(fecha_actual, "%Y")) - datos_2019_graph$birth_year
edad20 <- as.numeric(format(fecha_actual, "%Y")) - datos_2020_graph$birth_year
table(edad19)
#2019  
histogram4_19<- hist(edad19, 
                     main = "Edad de los usuarios de 2019",
                     xlab = "Kilómetros del viaje",
                     ylab = "Frecuencia",
                     col = "lightgreen", 
                     border = "black",   
                     breaks = 20) 
#2020
histogram4_19<- hist(edad20, 
                     main = "Edad de los usuarios de 2020",
                     xlab = "Kilómetros del viaje",
                     ylab = "Frecuencia",
                     col = "lightgreen", 
                     border = "black",   
                     breaks = 20) 



# Usertype de cada año

#2019
usertype_counts <- table(datos_2019_graph$usertype)
barplot(usertype_counts, col = c('darkgreen', 'grey'), main = 'Tipo de usuario 2019', xlab = 'User Type', ylab = 'Frecuencia')

#2020
usertype_counts <- table(datos_2020_graph$usertype)
barplot(usertype_counts, col = c('darkgreen', 'grey'), main = 'Tipo de usuario 2020', xlab = 'User Type', ylab = 'Frecuencia')


# Tipo de bicicletas usadas en 2022

biketype_counts <- table(datos_2022_graph$rideable_type)
barplot(biketype_counts, col = c('beige', 'grey'), main = 'Tipo de bicicleta usada en 2022', xlab = 'Bike Type', ylab = 'Frecuencia')

# Estaciones donde se cogen más bicicletas

#2019
station_count <- table(datos_2019_graph$start_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,5)
barplot(station_count, col = c('lightyellow', 'grey'), main = 'Estaciones donde se recogen más bicicletas 2019', xlab = 'Station Name', ylab = 'Frecuencia')

#2020
station_count <- table(datos_2020_graph$start_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,5)
barplot(station_count, col = c('lightyellow', 'grey'), main = 'Estaciones donde se recogen más bicicletas 2020', xlab = 'Station Name', ylab = 'Frecuencia')

#2022
station_count <- table(datos_2022_graph$start_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,5)
barplot(station_count, col = c('lightyellow', 'grey'), main = 'Estaciones donde se recogen más bicicletas 2022', xlab = 'Station Name', ylab = 'Frecuencia')


# Estaciones donde se devuelven más bicicletas

#2019
station_count <- table(datos_2019_graph$end_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,5)
barplot(station_count, col = c('aquamarine', 'grey'), main = 'Estaciones donde se devuelven más bicicletas 2019', xlab = 'Station Name', ylab = 'Frecuencia')

#2020
station_count <- table(datos_2020_graph$end_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,5)
barplot(station_count, col = c('aquamarine', 'grey'), main = 'Estaciones donde se devuelven más bicicletas 2020', xlab = 'Station Name', ylab = 'Frecuencia')

#2022
station_count <- table(datos_2022_graph$end_station_name)
station_count <- station_count[order(-station_count)]
station_count <- head(station_count,5)
barplot(station_count, col = c('aquamarine', 'grey'), main = 'Estaciones donde se devuelven más bicicletas 2022', xlab = 'Station Name', ylab = 'Frecuencia')


# Uso de las bicicletas por ID 2019/2020

#2019
bikeid_count <- table(datos_2019_graph$bikeid)
bikeid_count <- bikeid_count[order(-bikeid_count)]
bikeid_count <- head(bikeid_count, 10)
barplot(bikeid_count, col = c('mistyrose', 'grey'), main = 'Uso de las bicicletas por ID 2019', xlab = 'Bike ID', ylab = 'Frecuencia')

#2020
bikeid_count <- table(datos_2020_graph$bikeid)
bikeid_count <- bikeid_count[order(-bikeid_count)]
bikeid_count <- head(bikeid_count, 10)
barplot(bikeid_count, col = c('mistyrose', 'grey'), main = 'Uso de las bicicletas por ID 2020', xlab = 'Bike ID', ylab = 'Frecuencia')

table(datos_2019_graph$bikeid)
# ============================================================================================#


# ========================= IMPORTAMOS EL DATASET DE LOS ZIPCODES ============================

# Cambiamos directorio a donde se encuentra el dataset

setwd("C:/Users/alfre/OneDrive/Documentos/5º Carrera/TFG/TFG Business Analytics/R Studio")

# Cargamos el dataset

zipcodes <-  read_xlsx("ZipsNJ.xlsx")

# Insepeccionamos las variables

str(zipcodes)
summary(zipcodes)
sapply(zipcodes, class)


#-------------------------------------------------------------------------------------------#


