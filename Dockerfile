FROM sonarqube:lts-community

LABEL maintainer="Erik Jacobs <erikmjacobs@gmail.com>"
LABEL maintainer="Siamak Sadeghianfar <siamaksade@gmail.com>"
LABEL maintainer="Roland Stens (roland.stens@gmail.com)"
LABEL maintainer="Wade Barnes (wade@neoterictech.ca)"
LABEL maintainer="Emiliano Sune (emiliano.sune@gmail.com)"
LABEL maintainer="Alejandro Sanchez (emailforasr@gmail.com)"

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
ARG SONAR_ZAP_PLUGIN_VERSION=2.3.0
ARG COMUNITY_BRANCH_PLUGIN_VERSION=1.8.1
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

# Sonarqube Community Branch Plugin - https://github.com/mc1arke/sonarqube-community-branch-plugin
RUN set -x \
  && cd "$SONARQUBE_PLUGIN_DIR" \
  && curl -o "sonarqube-community-branch-plugin-$COMUNITY_BRANCH_PLUGIN_VERSION.jar" -fsSL "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/$COMUNITY_BRANCH_PLUGIN_VERSION/sonarqube-community-branch-plugin-$COMUNITY_BRANCH_PLUGIN_VERSION.jar"

WORKDIR $SONARQUBE_HOME

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UIDs.
RUN chown -R 1001:0 "$SONARQUBE_HOME" \
  && chgrp -R 0 "$SONARQUBE_HOME" \
  && chmod -R g+rwX "$SONARQUBE_HOME" \
  && chmod 775 "$SONARQUBE_HOME/bin/run.sh"

USER 1001
