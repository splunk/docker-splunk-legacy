#https://docs.docker.com/engine/reference/commandline/build/
if [ -z $CURRENT ]; then
	CURRENT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fi

docker build --no-cache=true -t splunk/splunk:6.6.2 .
docker tag splunk/splunk:6.6.2 splunk/splunk:latest 
docker tag splunk/splunk:6.6.2 registry.splunk.com/splunk/splunk:latest 
docker tag splunk/splunk:6.6.2 registry.splunk.com/splunk/splunk:6.6.2 