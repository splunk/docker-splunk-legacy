#https://docs.docker.com/engine/reference/commandline/build/
if [ -z $CURRENT ]; then
	CURRENT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fi


docker build -t splunk/universalforwarder:6.6.0 $CURRENT
docker build -t splunk/universalforwarder:latest $CURRENT

