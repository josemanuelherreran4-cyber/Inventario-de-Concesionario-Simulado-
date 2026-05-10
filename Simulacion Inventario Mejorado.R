# creando los vectores.
#tabla 1, Inventario autos, consesionaria, mes de agosto. 
library(ggplot2)
library(dplyr)
library(RSQLite)
library(DBI)
set.seed(110)


# tabla 1 Inventario dinamico
Marca1 <- c("Toyota", "Volkswagen", "Ford", "Honda", "Chevrolet", "Hyundai", "Nissan", "BMW", "Mercedes-Benz", "Kia", "Audi", "Mazda", "Subaru", "Tesla", "Fiat", "Renault", "Peugeot", "Suzuki", "Mitsubishi", "Volvo")
Modelo1 <- c("Corolla", "Hilux", "RAV4", "Golf", "Tiguan", "Polo", "F-150", "Mustang", "Explorer", "Civic", "CR-V", "Accord", "Silverado", "Onix", "Equinox", "Tucson", "Elantra", "Santa Fe", "Sentra", "Qashqai", "Frontier", "Serie 3", "X5", "M4", "Clase C", "GLE", "Clase S", "Sportage", "Rio", "Seltos", "A4", "Q5", "A3", "CX-5", "Mazda3", "CX-30", "Impreza", "Forester", "Outback", "Model 3", "Model Y", "Model S", "500", "Cronos", "Panda", "Clio", "Duster", "Sandero", "208", "3008", "2008", "Swift", "Vitara", "Jimny", "L200", "Outlander", "Montero", "XC60", "XC90", "S60")
Anio1Modelo <- c(2015:2025)
Tipo_transmicion1 <- c("Manual", "Automatica", "CVT")
Tipo_Combustible1 <- c("Gasolina", "Electrico", "Hibrido")
Condicion_a <- c("Nuevo", "Seminuevo")
Estado_a <- c("Disponible", "Reservado", "En Taller")
Precio_entrada1 <- c(26500, 44000, 39500, 31000, 38500, 22000, 75000, 68000, 52000, 29000, 36000, 41000, 69000, 18500, 34000, 33500, 24500, 46000, 25500, 35000, 42000, 58000, 95000, 125000, 62000, 98000, 155000, 31500, 19500, 28500, 45000, 56000, 38000, 34500, 27000, 31000, 29500, 37000, 43000, 48000, 54000, 95000, 21000, 19000, 17500, 20500, 26000, 18000, 24000, 42000, 32000, 18500, 28000, 24500, 39000, 35000, 55000, 65000, 85000, 52000)
Color1 <- c("Rojo", "Blanco","Azul", "Negro")
Mes_entrada1 <- seq(from = as.Date("2015-01-01"),
                   to = as.Date("2024-12-31"),
                   by = "month"
)

#Relaciono los modelos con las marcas
# Unimos Marca, Modelo y Precio en una sola referencia "Maestra"
Maestro_Referencia <- data.frame(
  Marca = rep(Marca1, each = 3),
  Modelos = Modelo1,
  Precio_entrada = Precio_entrada1,
  stringsAsFactors = FALSE
)

Diccionario_modelo

Estado_prob <- sample(Estado_a, size = 3000, replace = TRUE, prob = c(0.70, 0.22, 0.08))
N_inventario <- 3000

Inventario_tabla1 <- data.frame(
  ID_Vehiculo = sample((1:N_inventario), size =  N_inventario, replace = FALSE), 
  Marca = sample(Marca1, size = N_inventario, replace = N_inventario),
  Tipo_Combustible = sample(Tipo_Combustible1, size = N_inventario, replace = TRUE),
  Tipo_transmicion = sample(Tipo_transmicion1, size = N_inventario, replace = TRUE),
  Condicion = sample(Condicion_a, size = N_inventario, replace = TRUE, prob = c(0.65,0.35)),
  Anio = sample((2015:2024), size = N_inventario, replace = TRUE),
  Color = sample(Color1, size = N_inventario, replace = TRUE),
  Estado = Estado_prob,
  stringsAsFactors = FALSE)

View(Inventario_tabla1)

## Asignamos Modelos de forma coherente

#Relaciono los modelos con las marcas
# Unimos Marca, Modelo y Precio en una sola referencia "Maestra"

Inventario_tabla1 <- Inventario_tabla1 %>%
  rowwise() %>%
  mutate(Modelos = sample(Maestro_Referencia$Modelos[Maestro_Referencia$Marca == Marca], 1)) %>%
  ungroup()
## 
Inventario_tabla1 <- Inventario_tabla1 %>%
  left_join(Maestro_Referencia %>% select(Modelos, Precio_entrada), by = "Modelos")


# agregamos el mes de entrada tal que sea mayor al año del modelo.
Inventario_tabla1$Mes_entrada <- sapply((1:N_inventario), function(i) {
  Anio_auto <- Inventario_tabla1$Anio[i]
  fechas_validas <- Mes_entrada1[as.numeric(format(Mes_entrada1, "%Y")) >= Anio_auto]
  fecha_selecionada <- sample(fechas_validas, 1)
  return(as.character(fecha_selecionada))
})

Inventario_tabla1$Mes_entrada <- as.Date(Inventario_tabla1$Mes_entrada)

# agregamos la variable kilometraje segun su Condicion
n_filas_total <- nrow(Inventario_tabla1)

Inventario_tabla1$Kilometraje <- NA

# --- 2 Asignamos kilometraje a los autos NUEVOS
k_nuevos <- Inventario_tabla1$Condicion == "Nuevo"
kn_nuevos<- sum(k_nuevos)
kn_nuevos
Inventario_tabla1$Kilometraje[k_nuevos] <- sample(0:10, kn_nuevos, replace = TRUE)

# --- 2,1 kilometraje de usados con distribucion normal

anio_acutal <- 2025
antiguedad_autos <- anio_acutal-(Inventario_tabla1$Anio)
K_Seminuevo <- Inventario_tabla1$Condicion == "Seminuevo"

kn_Seminuevo <- sum(K_Seminuevo)

media_estimada <- antiguedad_autos[K_Seminuevo] * 12000

desviacion_std <- 4000

km_nomal <- rnorm(n = kn_Seminuevo, mean = media_estimada, sd = desviacion_std )

Inventario_tabla1$Kilometraje[K_Seminuevo] <- abs(as.integer(km_nomal))

View(Inventario_tabla1)

#corregumosmes de entrada
Inventario_tabla1$Mes_entrada <- as.Date(Inventario_tabla1$Mes_entrada, origin = "1970-01-01")
Inventario_tabla1$Mes_entrada <- format(Inventario_tabla1$Mes_entrada, "%Y/%m/%d")

plot_estado <- table(Inventario_tabla1$Estado)
plot_estado
barplot(plot_estado, 
        main = "Grafico por estado",
        xlab = "Estado automovil",
        ylab= "Cantidad autos", 
        col = c("steelblue", "orange", "darkgreen", "red")
        )
plot_estado <- table(Inventario_tabla1$Condicion)

plot_condicion <- table(Inventario_tabla1$Condicion)

barplot(plot_condicion, 
        main = "Grafico por estado",
        xlab = "Condicion automovil",
        ylab= "Cantidad autos", 
        col = c("steelblue", "orange", "darkgreen", "red")
)

# 10 Prueba de integridad de la tabla creada.
# a) contar Errores 
any(is.na(Inventario_tabla1)) # Devuelve TRUE si hay al menos uno

# revisa si el kilometraje no rompe la ley de los kilometros establecida.

errores_km <- Inventario_tabla1 %>%
  filter(Condicion == "Nuevo" & Kilometraje > 10)

cat("Cantidad de autos nuevos con exceso de kilometraje:", nrow(errores_km))


# c) 
errores_precio <- Inventario_tabla1 %>%
  left_join(Diccionario_modelo, by = c("Modelos" = "Modelo_rep")) %>%
  filter(Precio_entrada.x != Precio_entrada.y)

cat("Cantidad de registros con precios alterados:", nrow(errores_precio))

# d) validacion de probabilidad establecida

prop.table(table(Inventario_tabla1$Estado))
# Esto te mostrará si las proporciones reales coinciden con tu diseño

prop.table(table(Inventario_tabla1$Condicion))

# AUDITORIA FINAL 
auditoria_inventario <- function(df) {
  list(
    Nulos_Totales = sum(is.na(df)),
    Errores_KM_Nuevos = nrow(df[df$Condicion == "Nuevo" & df$Kilometraje > 10, ]),
    Duplicados_ID = sum(duplicated(df$ID_Vehiculo)),
    Rango_Precios_OK = range(df$Precio_entrada)
  )
}

# Ejecutar auditoría
reporte <- auditoria_inventario(Inventario_tabla1)
print(reporte)




### TABLA N2 vENTAS

Metodo_pagoBasic <- c("Contado", "Credito", "Leasing")
Descuento_Basic <- c(0.01, 0.02, 0.03, 0.03, 0.04, 0.05, 0.08, 0.09, 0.1, 0.13)
ID_vehiculosBasic <- Inventario_tabla1$ID_Vehiculo[Inventario_tabla1$Estado == "Disponible"]

# Caracteristicas tabla ventas 

n_a_vender <-floor(length(ID_vehiculosBasic)*0.8)
n_a_vender
Id_para_venta <-sample(ID_vehiculosBasic, size = n_a_vender, replace = FALSE)


#1:Qn_ventas cantidad de autos vendidos por que cada vez que corre el Modelo la cantidad deID puede variar

Ventas_tabla <- data.frame(
  ID_ventas = sample(1:n_a_vender, size = n_a_vender, replace = FALSE),
  ID_vehiculos = Id_para_venta,
  Metodo_pago = sample(Metodo_pagoBasic, size = n_a_vender, replace = TRUE),
  Descuento_porcentaje = sample(Descuento_Basic, size = n_a_vender, replace = TRUE)
)

sum(duplicated(Ventas_tabla$ID_vehiculos))
View(Ventas_tabla)

#agregamos indices en las tablas para la comparacion de ID, 
indice_ventas1 <- match(Ventas_tabla$ID_vehiculos, Inventario_tabla1$ID_Vehiculo)
Ventas_tabla$Fecha_entrada <- Inventario_tabla1$Mes_entrada[indice_ventas1]

# corregimos errores y revisamos los valores en la creacion de fechas 
Ventas_tabla$Fecha_entrada <- as.Date(Ventas_tabla$Fecha_entrada, origin = "1970-01-01")
if(any(is.na(Ventas_tabla$Fecha_entrada))) {
  stop("Hay valores NA en Fecha_entrada. Debes limpiarlos antes de generar la secuencia.")
}


fecha_limite <- as.Date("2025-12-31")
# agregamos las fechas de salida que sean maores alas fechas de entrada. 

Ventas_tabla$Fecha_venta <- as.Date(sapply(1:nrow(Ventas_tabla), function(i) {
  fecha_min <- Ventas_tabla$Fecha_entrada[i]
  Posibles_fechas <- seq(from = fecha_min, to = fecha_limite, by = "day")
  return(sample(Posibles_fechas, 1))
}), origin = "1970-01-01")


Ventas_tabla$Fecha_entrada <- NULL

# precio de entrada
Ventas_tabla$Precio_entrada <- Inventario_tabla1$Precio_entrada[indice_ventas1]
if(any(is.na(Ventas_tabla$Precio_entrada))) {
  warning("Se encontraron IDs en Ventas que no existen en el Inventario.")
}


#  precios de venta aumento. 
factor <- runif(nrow(Ventas_tabla), min = 1.10, max = 1.30)
Ventas_tabla$Precio_venta <- Ventas_tabla$Precio_entrada * factor
Ventas_tabla$Precio_venta <- round(Ventas_tabla$Precio_venta, 1)

#agregamos la cantidad de descuento
Ventas_tabla$Descuento_cantidad <- (Ventas_tabla$Precio_venta * Ventas_tabla$Descuento_porcentaje)

# corregimos las fechas
Ventas_tabla$Fecha_venta <- as.Date(Ventas_tabla$Fecha_venta, origin = "1970-01-01")
Ventas_tabla$Fecha_venta <- format(Ventas_tabla$Fecha_venta, "%Y/%m/%d")

Ventas_tabla$Precio_entrada <- NULL

##### 5 AGREGAMOS LA CONDICION DE QUE UNA VEZ REGISTRADO EN VENDIDO EL ESTADO CAMBIE EN INVENTARIO

Inventario_tabla1$Estado[Inventario_tabla1$ID_Vehiculo %in% Ventas_tabla$ID_vehiculos] <- "Vendido"

##   7 VALIDACIÓN DE LAS REGLAS DE NEGOCIO y DATOS EN VENTAS TABLA.
any(is.na(Ventas_tabla)) # Devuelve TRUE si hay al menos uno

# a )
check_estado_coherente <- Inventario_tabla1 %>%
  filter(ID_Vehiculo %in% Ventas_tabla$ID_vehiculos & Estado != "Vendido")

cat("Autos vendidos que aún figuran como Disponibles/Taller:", nrow(check_estado_coherente))

# Unimos con inventario para comparar fechas
check_fechas <- Ventas_tabla %>%
  left_join(Inventario_tabla1 %>% select(ID_Vehiculo, Mes_entrada), by = c("ID_vehiculos" = "ID_Vehiculo")) %>%
  filter(as.Date(Fecha_venta) < as.Date(Mes_entrada))

cat("Ventas con fecha imposible (antes de entrar al stock):", nrow(check_fechas))


# 5  Exportamos las tablas y limpiamos de datos extraños
library(readr)

getwd() # donde se guardan los archivos
setwd("C:/Users/hp/Documents/ESTUDIOS BI/practicas sqlite/3. Simulación mejorada Consecionaria") #cambio de lugar de guardado
getwd()

write.csv(Inventario_tabla1, "Inventario.csv", row.names = FALSE)
write.csv2(Ventas_tabla, "Ventas.csv", row.names = FALSE)

file.exists("Ventas.csv") # verifica si existe el archivo





