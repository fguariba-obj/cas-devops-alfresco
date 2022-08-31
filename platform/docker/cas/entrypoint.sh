#!/bin/bash
set -e

if [ "$SERVER_MODE" = "DEV" ]; then
  function require_value {
    test -n "$(printenv "$1")" && return
    echo "Error: $1 is not set"
    exit 1
  }

  require_value LDAP_CONFIG
  require_value LDAP_URL
  require_value LDAP_USER
  require_value LDAP_PASSWORD

  LDAP_AUTH_SOURCE_PATH="/opt/cas/ldap/$LDAP_CONFIG"
  LDAP_AUTH_TARGET_PATH="/usr/local/tomcat/shared/classes/alfresco/extension/subsystems/Authentication"

  function replace_value {
    local value="$(printenv "$2")"
    test -z "$value" && return
    sed -i "s/\${$2}/$(echo "$value" | sed -e 's/[\/&]/\\&/g')/g" "$1"
    echo "Replaced $2 in file $1"
  }

  # copy LDAP configuration:
  mkdir -p "$LDAP_AUTH_TARGET_PATH"
  cp -r "$LDAP_AUTH_SOURCE_PATH/"* "$LDAP_AUTH_TARGET_PATH/"

  for i in "$(find "$LDAP_AUTH_TARGET_PATH" -iname '*.properties')"
  do
    # fix permissions:
    chmod -x,g-w,o-rw "$i"

    # replace LDAP connection settings:
    replace_value "$i" LDAP_URL
    replace_value "$i" LDAP_USER
    replace_value "$i" LDAP_PASSWORD
  done
fi

exec /usr/local/tomcat/bin/catalina.sh run -security