# --- ETAPA 1: CONSTRUCCIÓN (Usando Java 21) ---
# Cambiamos la imagen base a una que tenga Maven y Java 21
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copiamos archivos de dependencias
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiamos el código fuente
COPY src ./src

# Compilamos
RUN mvn clean package -DskipTests

# --- ETAPA 2: EJECUCIÓN (Usando Java 21) ---
# La imagen final también debe ser Java 21 para poder correr lo que compilamos
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

# Copiamos el JAR generado
COPY --from=build /app/target/*.jar app.jar

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]