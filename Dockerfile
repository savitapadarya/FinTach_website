FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY . .
##Download all the dependencies defined in pom.xml before compiling the application
RUN mvn dependency:go-offline 
## Compile the application and package it into a jar file 
RUN mvn clean package -DskipTests
## The final stage of the build process, where we create a smaller image that only contains the compiled application and its runtime dependencies. This is done to reduce the size of the final image and improve security by excluding unnecessary build tools and files.
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
## Copy the compiled jar file from the builder stage to the final image 
COPY --from=builder /app/target/*.jar app.jar
## Expose the port that the application will listen on  
EXPOSE 8080
## Define the command to run the application when the container starts

#Healthcheck --interval=30s --timeout=5s --start-period=5s --retries=3 CMD curl -f http://localhost:8080/actuator/health || exit 1

CMD ["java", "-jar", "app.jar"]

