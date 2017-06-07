#https://docs.docker.com/engine/reference/commandline/build/
if [ -z $CURRENT ]; then
	CURRENT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fi

docker build --no-cache=true -t splunk/splunk:6.6.1 $CURRENT
docker tag splunk/splunk:6.6.1 splunk/splunk:latest $CURRENT
docker tag splunk/splunk:6.6.1 registry.splunk.com/splunk/splunk:latest $CURRENT
docker tag splunk/splunk:6.6.1 registry.splunk.com/splunk/splunk:6.6.1 $CURRENT