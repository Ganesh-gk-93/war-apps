FROM tomcat:10-jdk17
ARG APP_NAME
COPY wars/${APP_NAME}.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080