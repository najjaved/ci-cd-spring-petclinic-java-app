# create a Dockerfile that builds the application using Maven and packages the application into a minimal Docker image.

# Stage 1: Build the application
# Use the official Maven Docker image, which includes JDK 17, as the base image for the build stage.
FROM maven:3.8.5-openjdk-17-slim AS build

# Set the working directory in the container for running docker Cmds
WORKDIR /app

# Copy the pom.xml and src directory from local machine into the cuurent working directory inside the container i.e. /app/pom.xml & /app/src
COPY pom.xml .
COPY src ./src

# Build the Java application using Maven. This will create the .jar file in the /app/target directory.
RUN mvn clean package -DskipTests

# Stage 02: Create the runtime image- use a minimal JRE image for the runtime
FROM openjdk:17-jre-slim

WORKDIR /app

# Copy the packaged JAR from the build stage's /app/target directory to the runtime stage's working directory
COPY --from=build /app/target/*.jar ./petclinic.jar

# Expose port 8080, the default port for most Java web applications
EXPOSE 8080

# Defines the command to run the application when the container starts
CMD ["java", "-jar", "petclinic.jar"]
