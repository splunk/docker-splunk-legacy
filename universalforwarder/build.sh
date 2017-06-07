#https://docs.docker.com/engine/reference/commandline/build/
if [ -z $CURRENT ]; then
	CURRENT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fi


docker build --no-cache=true -t splunk/universalforwarder:6.6.1 $CURRENT
docker tag splunk/universalforwarder:6.6.1 splunk/universalforwarder:latest
docker tag splunk/universalforwarder:6.6.1 registry.splunk.com/splunk/universalforwarder:6.6.1
docker tag splunk/universalforwarder:6.6.1 registry.splunk.com/splunk/universalforwarder:latest


