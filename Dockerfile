FROM sonarqube:8.9.6-community

MAINTAINER Erik Jacobs <erikmjacobs@gmail.com>
MAINTAINER Siamak Sadeghianfar <siamaksade@gmail.com>
MAINTAINER Roland Stens (roland.stens@gmail.com)
MAINTAINER Wade Barnes (wade@neoterictech.ca)
MAINTAINER Emiliano Sune (emiliano.sune@gmail.com)
MAINTAINER Alejandro Sanchez (emailforasr@gmail.com)

ENV SUMMARY="SonarQube for bcgov OpenShift" \
    DESCRIPTION="This image creates the SonarQube image for use at bcgov/OpenShift"

LABEL summary="$SUMMARY" \
  description="$DESCRIPTION" \
  io.k8s.description="$DESCRIPTION" \
  io.k8s.display-name="sonarqube" \
  io.openshift.expose-services="9000:http" \
  io.openshift.tags="sonarqube" \
  release="$SONAR_VERSION"

# Define Plug-in Versions
ARG SONAR_ZAP_PLUGIN_VERSION=1.2.0
ENV SONARQUBE_PLUGIN_DIR="$SONARQUBE_HOME/extensions/plugins"

# Switch to root for package installs
USER 0
RUN apk update && \
    apk add curl

# ================================================================================================================================================================================
# Bundle Plug-in(s)
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# sonar-zap-plugin - https://github.com/Coveros/zap-sonar-plugin
RUN set -x \
  && cd "$SONARQUBE_PLUGIN_DIR" \
  && curl -o "sonar-zap-plugin-$SONAR_ZAP_PLUGIN_VERSION.jar" -fsSL "https://github.com/Coveros/zap-sonar-plugin/releases/download/sonar-zap-plugin-$SONAR_ZAP_PLUGIN_VERSION/sonar-zap-plugin-$SONAR_ZAP_PLUGIN_VERSION.jar"

WORKDIR $SONARQUBE_HOME

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UIDs.
RUN chown -R 1001:0 "$SONARQUBE_HOME" \
  && chgrp -R 0 "$SONARQUBE_HOME" \
  && chmod -R g+rwX "$SONARQUBE_HOME" \
  && chmod 775 "$SONARQUBE_HOME/bin/run.sh"

USER 1001
