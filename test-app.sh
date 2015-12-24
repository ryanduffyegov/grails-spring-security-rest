#!/bin/bash

set -e

[[ ! -z "$BINTRAY_KEY" ]] && echo "bintrayKey=$BINTRAY_KEY" >> ~/.gradle/gradle.properties
[[ ! -z "$PLUGIN_PORTAL_PASSWORD" ]] && echo "pluginPortalPassword=$PLUGIN_PORTAL_PASSWORD" >> ~/.gradle/gradle.properties

./gradlew exportVersion
export pluginVersion=`cat spring-security-rest/build/version.txt`
export grailsVersion=`cat spring-security-rest-testapp-profile/gradle.properties | grep grailsVersion | sed -n 's/^grailsVersion=//p'`

echo "Plugin version: $pluginVersion. Grails version for profiles: $grailsVersion"
source ~/.sdkman/bin/sdkman-init.sh
sdk use grails $grailsVersion

./gradlew clean install \
  && cd build && rm -rf * \
  && for feature in jwt1 jwt2 ; do
     grails create-app -profile org.grails.plugins:spring-security-rest-testapp-profile:$pluginVersion -features $feature $feature && cd $feature && ./gradlew check && cd ..
     if [ $? -ne 0 ]; then
       echo -e "\033[0;31mTests FAILED\033[0m"
       exit -1
     fi
     done \
  && cd .. \
  && ./gradlew artifactoryPublish