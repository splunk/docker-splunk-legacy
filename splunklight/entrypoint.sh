#!/bin/bash

set -e

if [ "$1" = 'splunk' ]; then
  shift
  sudo -HEu ${SPLUNK_USER} ${SPLUNK_HOME}/bin/splunk "$@"
elif [ "$1" = 'start-service' ]; then
  # If user changed SPLUNK_USER to root we want to change permission for SPLUNK_HOME
  if [[ "${SPLUNK_USER}:${SPLUNK_GROUP}" != "$(stat --format %U:%G ${SPLUNK_HOME})" ]]; then
    chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_HOME}
  fi

  # If version file exists already - this Splunk has been configured before
  __configured=false
  if [[ -f ${SPLUNK_HOME}/etc/splunk.version ]]; then
    __configured=true
  fi

  __license_ok=false
  # If these files are different override etc folder (possible that this is upgrade or first start cases)
  # Also override ownership of these files to splunk:splunk
  if ! $(cmp --silent /var/opt/splunk/etc/splunk.version ${SPLUNK_HOME}/etc/splunk.version); then
    cp -fR /var/opt/splunk/etc ${SPLUNK_HOME}
    chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} $SPLUNK_HOME/etc
    chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} $SPLUNK_HOME/var
  else
    __license_ok=true
  fi

  if tty -s; then
    __license_ok=true
  fi

  if [[ "$SPLUNK_START_ARGS" == *"--accept-license"* ]]; then
    __license_ok=true
  fi

  if [[ $__license_ok == "false" ]]; then
    cat << EOF
Splunk Light
==============

  Available Options:

      - Launch container in Interactive mode "-it" to review and accept
        end user license agreement
      - If you have reviewed and accepted the license, start container
        with the environment variable:
            SPLUNK_START_ARGS=--accept-license

  Usage:

    docker run -it outcoldman/splunk:latest-light
    docker run --env SPLUNK_START_ARGS="--accept-license" outcoldman/splunk:latest-light

EOF
    exit 1
  fi

  sudo -HEu ${SPLUNK_USER} ${SPLUNK_HOME}/bin/splunk start ${SPLUNK_START_ARGS}
  trap "sudo -HEu ${SPLUNK_USER} ${SPLUNK_HOME}/bin/splunk stop" SIGINT SIGTERM EXIT

  # If this is first time we start this splunk instance
  if [[ $__configured == "false" ]]; then
    # Setup listening
    # http://docs.splunk.com/Documentation/Splunk/latest/Forwarding/Enableareceiver
    if [[ -n ${SPLUNK_ENABLE_LISTEN} ]]; then
      sudo -HEu ${SPLUNK_USER} sh -c "${SPLUNK_HOME}/bin/splunk enable listen ${SPLUNK_ENABLE_LISTEN} -auth admin:changeme ${SPLUNK_ENABLE_LISTEN_ARGS}"
    fi

    # Setup monitoring
    # http://docs.splunk.com/Documentation/Splunk/latest/Data/MonitorfilesanddirectoriesusingtheCLI
    # http://docs.splunk.com/Documentation/Splunk/latest/Data/Monitornetworkports
    if [[ -n ${SPLUNK_ADD} ]]; then
        sudo -HEu ${SPLUNK_USER} sh -c "${SPLUNK_HOME}/bin/splunk add ${SPLUNK_ADD} -auth admin:changeme"
    fi
    for n in {1..30}; do
      if [[ -n $(eval echo \$\{SPLUNK_ADD_${n}\}) ]]; then
        sudo -HEu ${SPLUNK_USER} sh -c "${SPLUNK_HOME}/bin/splunk add $(eval echo \$\{SPLUNK_ADD_${n}\}) -auth admin:changeme"
      else
        # We do not want to iterate all, if one in the sequence is not set
        break
      fi
    done

    # Execute anything
    if [[ -n ${SPLUNK_CMD} ]]; then
        sudo -HEu ${SPLUNK_USER} sh -c "${SPLUNK_HOME}/bin/splunk ${SPLUNK_CMD}"
    fi
    for n in {1..30}; do
      if [[ -n $(eval echo \$\{SPLUNK_CMD_${n}\}) ]]; then
        sudo -HEu ${SPLUNK_USER} sh -c "${SPLUNK_HOME}/bin/splunk $(eval echo \$\{SPLUNK_CMD_${n}\})"
      else
        # We do not want to iterate all, if one in the sequence is not set
        break
      fi
    done
  fi

  sudo -HEu ${SPLUNK_USER} tail -n 0 -f ${SPLUNK_HOME}/var/log/splunk/splunkd_stderr.log &
  wait
elif [ "$1" = 'splunk-bash' ]; then
  source /opt/splunk/bin/setSplunkEnv
  cd $SPLUNK_HOME
  su splunk
else
  "$@"
fi
