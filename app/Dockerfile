FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /src

COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests

FROM tomcat:9-jre17-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /src/target/hello.war /usr/local/tomcat/webapps/hello.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
