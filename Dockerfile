FROM tomcat:8.0.20-jre8
COPY target/*.jar /usr/local/tomcat/webapps/myprojectapp.jar
