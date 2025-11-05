# ============================================================
# MATRIZ DE CONFUSIÓN Y VISUALIZACIÓN DE FALSOS POSITIVOS/NEGATIVOS
# ============================================================

# Instalar y cargar librerías necesarias.
#install.packages("caret")
#install.packages("ggplot2")
#install.packages("hardhat")
#install.packages("lava")
#install.packages("lattice")
#install.packages("purrr")
#install.packages("e1071")
#library(caret)
library(ggplot2)

# ============================
# 1. Cargar tus datos desde una ruta (archivo CSV)
# ============================
data_frame_real <- read.csv("~/Downloads/validation_predictions.csv")
Real <- as.character(data_frame_real$true_label)

data_frame_prediccion <- read.csv("~/Downloads/validation_predictions.csv")
Prediccion <- as.character(data_frame_prediccion$predicted_label)

# Combinar ambos vectores en un solo data frame.
datos <- data.frame(Real, Prediccion)


# ============================
# 2. Especificar columnas
# ============================
real <- factor(datos$Real, levels =c ("0","1"))         # columna real (0/1)
prediccion <- factor(datos$Prediccion, levels =c ("0","1")) # columna predicha (salida del modelo)

# ============================
# 3. Crear matriz de confusión
# ============================
matriz <- table(Prediccion = prediccion, Real = real)
print(matriz)

# ============================
# 4. Extraer valores
# ============================
# Recuerda: filas = predicción, columnas = valor real

TP <- matriz["1", "1"] # True Positive
TN <- matriz["0", "0"] # True Negative
FP <- matriz["1", "0"] # False Positive
FN <- matriz["0", "1"] # False Negative

cat("\n--- Valores ---\n")
cat("TP:", TP, "\n")
cat("TN:", TN, "\n")
cat("FP:", FP, "\n")
cat("FN:", FN, "\n")

# ============================
# 5. Calcular métricas
# ============================
sensibilidad <- TP / (TP + FN)
especificidad <- TN / (TN + FP)
precision <- TP / (TP + FP)
npv <- TN / (TN + FN)
accuracy <- (TP + TN) / (TP + TN + FP + FN)
f1 <- 2 * (precision * sensibilidad) / (precision + sensibilidad)

cat("\n--- Métricas ---\n")
cat("Sensibilidad (Recall):", round(sensibilidad, 3), "\n")
cat("Especificidad:", round(especificidad, 3), "\n")
cat("Precisión (PPV):", round(precision, 3), "\n")
cat("Valor Predictivo Negativo (NPV):", round(npv, 3), "\n")
cat("Accuracy:", round(accuracy, 3), "\n")
cat("F1 Score:", round(f1, 3), "\n")

# ============================
# 6. Representación gráfica
# ============================
resultados <- data.frame(
  Tipo = c("True Positives (TP)", "True Negatives (TN)",
           "False Positives (FP)", "False Negatives (FN)"),
  Cantidad = c(TP, TN, FP, FN)
)

ggplot(resultados, aes(x = Tipo, y = Cantidad, fill = Tipo)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = Cantidad), vjust = -0.4, size = 4) +
  scale_fill_manual(values = c("red2", "orangered", "green3", "darkgreen")) +
  labs(title = "Distribución de Verdaderos y Falsos Positivos/Negativos",
       x = "Tipo de resultado",
       y = "Número de casos") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

# ============================
# 7. Diagrama circular FP vs FN
# ============================
fp_fn <- data.frame(
  Tipo = c("False Positives (FP)", "False Negatives (FN)"),
  Cantidad = c(FP, FN)
)

ggplot(fp_fn, aes(x = "", y = Cantidad, fill = Tipo)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(round(Cantidad / sum(Cantidad) * 100, 1), "%")),
            position = position_stack(vjust = 0.5),
            color = "white",
            size = 5) +
  scale_fill_manual(values = c("red2", "orangered")) +
  labs(title = "Proporción de FP vs FN") +
  theme_void(base_size = 13)


# ============================
# 8. Otras representaciones (tener en cuenta la edad)
# ============================
notas_medicas <- as.character(data_frame_real$text)
edades <- c()
for (notas in notas_medicas){
  edad_encontrada <- regmatches(notas, 
    regexpr("(?i)\\b(?:edad[: ]*|age[: ]*|aged[:]*|[0-9*]-year-old[:]*|[0-9*]-years-old[:]*|\\b)(\\d{1,3})(?=\\s*(años?|years?))?", notas, perl = TRUE)
  )
  edad_num <- as.numeric(gsub("\\D", "", edad_encontrada))
  if (length(edad_num) > 0 && !is.na(edad_num)) {
    edades <- c(edades, edad_num)
  } else {
    edades <- c(edades, 0)
  }
}
print(edades)

# Suponiendo que tu data.frame se llama 'datos'
# y tiene las columnas "Real", "Prediccion" y "Edad"

# Crear una nueva columna 'Tipo' con el mismo número de filas
datos[ , "Tipo"] <- NA
datos[ , "Edad"] <- edades

# Clasificación: TP, TN, FP, FN
datos[ datos[ , "Real"] == "1" & datos[ , "Prediccion"] == "1", "Tipo" ] <- "TP"
datos[ datos[ , "Real"] == "0" & datos[ , "Prediccion"] == "0", "Tipo" ] <- "TN"
datos[ datos[ , "Real"] == "0" & datos[ , "Prediccion"] == "1", "Tipo" ] <- "FP"
datos[ datos[ , "Real"] == "1" & datos[ , "Prediccion"] == "0", "Tipo" ] <- "FN"

# Crear la matriz edad ↔ tipo (solo esas dos columnas)
matriz_edad_tipo <- datos[ , c("Edad", "Tipo") ]

# Mostrar la matriz
print(matriz_edad_tipo)

matriz_resumen <- table(datos[ , "Edad"], datos[ , "Tipo"])
print(matriz_resumen)


#REPRESENTACIÓN
# Crear la columna de franja etaria
datos_filtrados <- datos[ datos[ , "Edad"] > 17, ]
datos_filtrados[ , "Franja"] <- cut(
  datos_filtrados[ , "Edad"],
  breaks = c(17, 24, 64, 100),
  labels = c("Adulto joven (18-24)", "Adulto (25-64)", "Adulto mayor (>65)")
)

tabla_franja <- table(datos_filtrados[ , "Franja"], datos_filtrados[ , "Tipo"])
print(tabla_franja)

tabla_df <- as.data.frame(tabla_franja)
colnames(tabla_df) <- c("Franja", "Tipo", "Frecuencia")

barplot(
  t(tabla_franja),
  beside = TRUE,
  col = c("red3", "orange", "green3", "darkgreen"),
  legend.text = TRUE,
  args.legend = list(x = "topleft", bty = "n", title = "Tipo"),
  main = "Distribución de resultados por franja de edad (Edad encontrada)",
  xlab = "Franja etaria",
  ylab = "Frecuencia"
)