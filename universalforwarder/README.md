# Supported tags

* `7.0.3`, `latest` - Splunk universal forwarder base image [Dockerfile](https://github.com/splunk/docker-splunk/blob/master/enterprise/Dockerfile)
* `6.5.3-monitor` - Splunk universal forwarder with Docker Monitoring [Dockerfile](https://github.com/splunk/docker-itmonitoring/blob/master/universalforwarder/Dockerfile)

# What is the Splunk Universal Forwarder?

Splunk is the platform for operational intelligence. The software lets you collect, analyze, and act upon the untapped value of big data that your technology infrastructure, security systems, and business applications generate. It gives you insights to drive operational performance and business results.

Splunk Universal Forwarders provide reliable, secure data collection from remote sources and forward that data into Splunk (Enterprise, Light, Cloud or Hunk) for indexing and consolidation. They can scale to tens of thousands of remote systems, collecting terabytes of data with minimal impact on performance.

This repository contains Dockerfiles that you can use to build [Splunk](https://splunk.com) Universal Forwarder Docker images.

# Get started with the Splunk universal forwarder Docker Image

If you have not used Docker before, see the [Getting started tutorial](https://docs.docker.com/mac/started) for Docker. 

0. (Optional) Sign up for a Docker ID at [Docker Hub](https://hub.docker.com).
0. Download and install Docker on your system.
0. Open a shell prompt or Terminal window.
0. Enter the following command to pull the Splunk Enterprise version 7.0.3 image.<br>

   
   ```bash
   docker pull splunk/universalforwarder:latest
   ```
0. Run the Docker image.
   
   ```bash
   docker run --name splunkuniversalforwarder \
     --env SPLUNK_START_ARGS=--accept-license \
       --env SPLUNK_FORWARD_SERVER=splunk_ip:9997 \
     --env SPLUNK_USER=root \
     --volume /var/lib/docker/containers:/host/containers:ro \
     --volume /var/log:/docker/log:ro \
       --volume /var/run/docker.sock:/var/run/docker.sock:ro \
       --volume volume_splunkuf_etc:/opt/splunk/etc \
       --volume volume_splunkuf_var:/opt/splunk/var \
       -d splunk/universalforwarder:6.5.3-monitor
   ```

See [How to use the universal forwarder Docker image](#how-to-use-the-universal-forwarder-docker-image) for additional example commands.

# How to use the universal forwarder Docker image

The universal forwarder docker image can collect data from a host and send data to another host. If you pull the image with the '6.5.3-monitor` tag, the forwarder container includes the Docker data collection inputs.


The following commands are examples of how to pull and run the universal forwarder Docker image. They can be run from a shell prompt or Docker QuickStart Terminal (on Mac OS X).

### Pull an image from this repository for the universal fowarder with the Docker data collection inputs
The `7.0.3-monitor` tag ensures that the universal forwarder has the data inputs you need to get stats from a Docker container.

```bash
docker pull splunk/universalforwarder:7.0.3-monitor
```

### Pull the latest version of the image from this repository
The `7.0.3` and `latest` versions only have the forwarder and do not have any of the data inputs.
=======
The `6.5.3-monitor` tag ensures that the universal forwarder has the data inputs you need to get stats from a Docker container.

```bash
docker pull splunk/universalforwarder:6.5.3-monitor
```


```bash
docker pull splunk/universalforwarder:latest
```

### Start a universal forwarder container and automatically accept the license agreement

This command starts a universal forwarder instance from the Docker container in this repository, accepts the license agreement, and opens TCP port 8000 so that you can access the Splunk instance from your local machine.

```bash
docker run --name splunk --hostname splunk -d -e "SPLUNK_START_ARGS=--accept-license" splunk/universalforwarder
```
### Start a universal forwarder container and mount the necessary container volumes

```bash
docker run --name vsplunk -v /opt/splunk/etc -v /opt/splunk/var busybox
docker run --hostname splunk --name splunk --volumes-from=vsplunk -d -e "SPLUNK_START_ARGS=--accept-license" splunk/universalforwarder
```

### Use entrypoint.sh to execute Splunk commands

You can execute commands in the container by typing in the following command, for example:

```
docker exec splunk entrypoint.sh splunk version
```

To learn about the commands you can use with entrypoint.sh, see [Administrative CLI commands](https://docs.splunk.com/Documentation/Splunk/latest/Admin/CLIadmincommands) in the Splunk documentation.

You can also use entrypoint.sh to configure Splunk services with environment variables. See [Basic configuration with environment variables](#basic-configuration-with-environment-variables).

# Configure the universal forwarder Docker container with [docker-compose](https://docs.docker.com/compose/)

0. At a shell prompt, create a text file `docker-compose.yml` if it does not already exist.
0. Open `docker-compose.yml` for editing.
0. Insert the following block of text into the file.

```
version: '3'

volumes:
  opt-splunk-etc:
  opt-splunk-var:

services:
  splunkuniversalforwarder:

    hostname: splunkuniversalforwarder
    image: splunk/universalforwarder:7.0.3
    environment: SPLUNK_START_ARGS: --accept-license
    volumes:
      - opt-splunk-etc:/opt/splunk/etc
      - opt-splunk-var:/opt/splunk/var
    ports:
      - "8000:8000"
      - "9997:9997"
      - "8088:8088"
      - "1514:1514"
   ```
0. Save the file and close it.
0. Run the `docker-compose` utility.
   ```
   docker-compose up
   ```

## Configuration

### Image Variants

The `splunk/universalforwarder` image comes in the following variants:

`splunk/universalforwarder:7.0.3` and `splunk/universalforwarder:latest`
This is the default universal forwarder image.

`splunk/universalforwarder:6.5.3-monitor`
This image comes with some data inputs activated.

### Data Store

This image has two data volumes:

* `/opt/splunk/etc` - stores Splunk configurations, including applications and lookups
* `/opt/splunk/var` - stores indexed data, logs and internal Splunk data

### User

All Splunk processes run under the `root` user.

### Ports

This Docker container exposes the following network ports:

* `8089/tcp` - Splunk Services
* `8191/tcp` - Application Key Value Store
* `1514/tcp` - Network Input (not used by default) (All Splunk products)
* `8088/tcp` - HTTP Event Collector

This Docker image uses port 1514 instead of the standard port 514 for the syslog port because network ports below 1024 require root access. See [Run Splunk Enterprise as a different or non-root user](http://docs.splunk.com/Documentation/Splunk/latest/Installation/RunSplunkasadifferentornon-rootuser).

### Hostname

When you use this Docker image, set a `hostname` for it. If you recreate the instance later, the image retains the hostname.

### Basic configuration with Environment Variables

You can use environment variables for basic configuration of the indexer and forwarder. For more advanced configuration, create configuration files within the container or use a Splunk deployment server to deliver configurations to the instance.

- `SPLUNK_DEPLOYMENT_SERVER='<servername>:<port>` - [configure deployment
    client](http://docs.splunk.com/Documentation/Splunk/latest/Updating/Configuredeploymentclients).
    Set deployment server url.
    - Example: `--env SPLUNK_DEPLOYMENT_SERVER='splunkdeploymentserver:8089'`.
- `SPLUNK_FORWARD_SERVER=<servername>:<port>` - [forward](http://docs.splunk.com/Documentation/Splunk/latest/Forwarding/Deployanixdfmanually)
    data to indexer.
    - Additional configuration is available using `SPLUNK_FORWARD_SERVER_ARGS`
        environment variable.
    - Additional forwarders can be set up using `SPLUNK_FORWARD_SERVER_<1..30>`
        and `SPLUNK_FORWARD_SERVER_<1..30>_ARGS`.
    - Example: `--env SPLUNK_FORWARD_SERVER='splunkindexer:9997' --env
        SPLUNK_FORWARD_SERVER_ARGS='method clone' --env
        SPLUNK_FORWARD_SERVER_1='splunkindexer2:9997' --env
        SPLUNK_FORWARD_SERVER_1_ARGS='-method clone'`.
 `SPLUNK_ADD='<monitor|add> <what_to_monitor|what_to_add>'` - execute add command,
    for example to [monitor files](http://docs.splunk.com/Documentation/Splunk/latest/Data/MonitorfilesanddirectoriesusingtheCLI)
    or [listen](http://docs.splunk.com/Documentation/Splunk/latest/Data/Monitornetworkports) on specific ports.
    - Additional add commands can be executed (up to 30) using
        `SPLUNK_ADD_<1..30>`.
    - Example `--env SPLUNK_ADD='udp 1514' --env SPLUNK_ADD_1='monitor /var/log/*'`.
- `SPLUNK_CMD='any splunk command'` - execute any splunk command.
    - Additional commands can be executed (up to 30) using
        `SPLUNK_CMD_<1..30>`.
    - Example `--env SPLUNK_CMD='edit user admin -password random_password -role
        admin -auth admin:changeme'`.

#### Example

Following is an example of how to configure Splunk Enterprise and the Splunk universal forwarder in Docker.

```
> echo "Creating docker network, so all containers will see each other"
> docker network create splunk
> echo "Starting deployment server for forwarders"
> docker run -d --net splunk \
    --hostname splunkdeploymentserver \
    --name splunkdeploymentserver \
    --publish 8000 \
    --env SPLUNK_ENABLE_DEPLOY_SERVER=true \
    splunk/enterprise
> echo "Starting Splunk Enterprise"
> docker run -d --net splunk \
    --hostname splunkenterprise \
    --name splunkenterprise \
    --publish 8000 \
    --env SPLUNK_ENABLE_LISTEN=9997 \
    splunk/enterprise
> echo "Starting forwarder, which forwards data to Splunk"
> docker run -d --net splunk \
    --name forwarder \
    --hostname forwarder \
    --env SPLUNK_FORWARD_SERVER='splunkenterprise:9997' \
    --env SPLUNK_FORWARD_SERVER_ARGS='-method clone' \
    --env SPLUNK_ADD='udp 1514' \
    --env SPLUNK_DEPLOYMENT_SERVER='splunkdeploymentserver:8089' \
    splunk/universalforwarder
```

After this script executes, you can forward syslog data to the *udp*
port of container *forwarder* (for internal containers only, as Splunk
does not publish the port.) Data should arrive at both indexers and 
you should see the forwarder register with the deployment server.

# Troubleshoot problems with the image

## Basic troubleshooting

If you do not see data when you load the Docker Overview app in the Docker app, confirm that:

* You have started the container with the right environment variables. In particular, you must have the proper access control to the mount points to read the default JSON log files that the docker host collects. See [Required Permissions](#required-permissions) for more detail.
* You have included the necessary volumes for the Docker image.
* Your Docker container has the correct filesystem permissions.

### Required Permisssions
The following mount points require special permissions:
- `/var/lib/docker/containers`: By default, the Docker host only exposes read access to the root user. Read access to the volume could be changed for any users that start the Splunk process.
- `/var/run/docker.sock` - Requires access to the [Docker Remote API](https://docs.docker.com/engine/reference/api/docker_remote_api/) to collect information such as docker stats, tops, events, and inspect.

Overriding the SPLUNK_USER environment variable to an authorized user (such as "root") gives you the required access to the mount points that the Docker app needs to analyze the collected Docker information.

## Troubleshoot upgrade problems with docker-compose

If you use `docker-compose` (or reference an existing volume with `docker run`) to configure and run your Docker image and the container detects an upgrade after you make a change to `docker-compose.yml`, complete the following procedure to make the image ignore the upgrade prompt:

0. Open `docker-compose.yml` for editing.
0. In the `Environment:` section for the universal forwarder image, add the following line:
   
   ```
   SPLUNK_START_ARGS: --accept-license --answer-yes
   ```
0. Save `docker-compose.yml` and close it.
0. Run `docker-compose up` again.

## If you still need help

If you still have trouble forwarding data with the Splunk universal forwarder Docker image, use one of the following options:

* Post a question to [Splunk Answers](http://answers.splunk.com)
* Join the [Splunk Slack channel](http://splunk-usergroups.slack.com)
* Visit the #splunk channel on [EFNet Internet Relay Chat](http://www.efnet.org).
* Send an email to [docker-maint@splunk.com](mailto:docker-maint@splunk.com).
