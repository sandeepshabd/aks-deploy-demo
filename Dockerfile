# Step 1: Build the application
FROM openjdk:17 as builder
WORKDIR application

# Copy Gradle Wrapper files
COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts build.gradle.kts
COPY settings.gradle.kts settings.gradle.kts
COPY src src

# Grant execution permissions and build the project
RUN chmod +x ./gradlew && ./gradlew build

# Unpack the built JAR
RUN java -Djarmode=layertools -jar build/libs/*.jar extract

# Step 2: Create the Docker image
FROM openjdk:17
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./

# Define the entry point
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
