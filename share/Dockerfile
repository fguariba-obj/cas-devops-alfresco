ARG ALFRESCO_SHARE_VERSION
FROM quay.io/alfresco/alfresco-share:${ALFRESCO_SHARE_VERSION}
ENV TZ=Europe/Zurich
ARG TOMCAT_HOME=/usr/local/tomcat

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

# Copy overlay file(s)
COPY docker/tomcat "$TOMCAT_HOME"
COPY target/*.amp $TOMCAT_HOME/amps_share

# Install AMPs
RUN \
  java \
    -jar "$TOMCAT_HOME/alfresco-mmt/alfresco-mmt"*.jar \
      install \
      "$TOMCAT_HOME/amps_share" \
      "$TOMCAT_HOME/webapps/share" \
      -directory \
      -nobackup \
      -force