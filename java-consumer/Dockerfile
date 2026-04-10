FROM maven:3.9-eclipse-temurin-8 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn package -DskipTests -q
RUN mvn dependency:build-classpath -Dmdep.outputFile=/tmp/cp.txt -q

FROM eclipse-temurin:8-jre
WORKDIR /app
COPY --from=build /app/target/classes ./target/classes
COPY --from=build /root/.m2 /root/.m2
COPY --from=build /tmp/cp.txt /tmp/cp.txt
CMD java -cp "target/classes:$(cat /tmp/cp.txt)" com.demo.aq.OrderConsumer
