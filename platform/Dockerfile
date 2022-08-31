ARG ALFRESCO_REPO_VERSION
FROM quay.io/alfresco/alfresco-content-repository:${ALFRESCO_REPO_VERSION}
ENV TZ=Europe/Zurich
ARG TOMCAT_HOME=/usr/local/tomcat

ENTRYPOINT [ "/opt/cas/entrypoint.sh" ]

COPY --chown=root:Alfresco docker/cas /opt/cas
COPY --chown=root:Alfresco docker/amps/*.amp target/*.amp $TOMCAT_HOME/amps/

USER root

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
# Ensure the entrypoint script has the executable bit set:
RUN chmod +x /opt/cas/entrypoint.sh

RUN \
  java \
    -jar $TOMCAT_HOME/alfresco-mmt/alfresco-mmt*.jar \
      install \
      $TOMCAT_HOME/amps \
      $TOMCAT_HOME/webapps/alfresco \
      -directory \
      -nobackup \
      -force