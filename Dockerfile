FROM ubuntu
MAINTAINER Supeerawong Pothikanit

#install necessary
RUN apt-get update -y && \
	apt-get install software-properties-common -y && \
	add-apt-repository ppa:webupd8team/java -y && \
	apt-get update -y && \
	echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
	echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections && \
	apt-get install oracle-java8-installer -y && \
	apt-get install wget -y && \
	apt-get install curl -y && \
	apt-get install supervisor -y

#install alfresco
RUN wget https://download.alfresco.com/release/community/201707-build-00028/alfresco-community-installer-201707-linux-x64.bin && \
	chmod +x ./*.bin && \
	./alfresco-community-installer-201707-linux-x64.bin --mode unattended --alfresco_admin_password admin --prefix /alfresco
RUN rm ./alfresco-community-installer-201707-linux-x64.bin

#COPY alfresco-community-installer-201707-linux-x64.bin ./alfresco-community-installer-201707-linux-x64.bin
#RUN ./alfresco-community-installer-201707-linux-x64.bin --mode unattended --alfresco_admin_password admin --prefix /alfresco && \
#	rm ./alfresco-community-installer-201707-linux-x64.bin

#install mysql connector
RUN wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.43.tar.gz && \
	tar xvzf mysql-connector-java-5.1.43.tar.gz mysql-connector-java-5.1.43/mysql-connector-java-5.1.43-bin.jar && \
	mv mysql-connector-java-5.1.43/mysql-connector-java-5.1.43-bin.jar /alfresco/tomcat/lib

# LDAP configuration
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/
RUN mkdir -p /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/
COPY assets/ldap-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap/ldap1/ldap-authentication.properties
COPY assets/ldap-ad-authentication.properties /alfresco/tomcat/shared/classes/alfresco/extension/subsystems/Authentication/ldap-ad/ldap1/ldap-ad-authentication.properties

#backup alf_data
#RUN rsync -av /alfresco/alf_data /alf_data.install/

# adding path file used to disable tomcat CSRF
COPY assets/disable_tomcat_CSRF.patch /alfresco/disable_tomcat_CSRF.patch

#install script
COPY assets/init.sh /alfresco/init.sh
COPY assets/supervisord.conf /etc/supervisord.conf

RUN chmod 755 /etc/supervisord.conf && \
	chmod 755 /alfresco/init.sh 

RUN mkdir -p /alfresco/tomcat/webapps/ROOT
COPY assets/index.jsp /alfresco/tomcat/webapps/ROOT/

VOLUME /alfresco/alf_data
VOLUME /alfresco/tomcat/logs
VOLUME /content

EXPOSE 21 137 138 139 445 7070 8009 8080
CMD /usr/bin/supervisord -c /etc/supervisord.conf -n
