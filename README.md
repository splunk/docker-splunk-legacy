# Table of Contents

- [Supported tags](#supported-tags)
- [Introduction](#introduction)
    - [Version](#version)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Data Store](#data-store)
    - [User](#user)
    - [Ports](#ports)
    - [Entrypoint](#entrypoint)
    - [Hostname](#hostname)
    - [Basic configuration using Environment Variables](#basic-configuration-using-environment-variables)
        - [Example](#example)
- [Upgrade from previous version](#upgrade-from-previous-version)

## Supported tags

Current branch:

* `6.4`, `6.4.0`, `latest` - Splunk Enterprise
* `6.4-light`, `6.4.0-light`, `latest-light` - Splunk Light
* `6.4-forwarder`, `6.4.0-forwarder`, `latest-forwarder` - Splunk Universal Forwarder

For previous versions or newest releases see other branches.

## Introduction

> NOTE: I'm working at Splunk, but this is not an official Splunk images.
> I build them in my free time when I'm not at work. I have some knowledge
> about Splunk, but you should think twice before putting them in
> production. I run these images on my own home server just for
> my personal needs. If you have any issues - feel free to open a
> [bug](https://github.com/outcoldman/docker-splunk/issues).

Dockerfiles to build [Splunk](https://splunk.com) including Enterpise, Light and Universal Forwarder.

> Examples below show you how to pull and start Splunk Enterprise. If you want to use Splunk Light or Universal Forwarder - you just need to change tags to add `-light` or `-forwarder` and use `splunklight` and `universalforwarder` folders.

### Version

* Version: `6.4.0`
* Build: `f3e41e4b37b2`

## Installation

Pull the image from the [docker registry](https://registry.hub.docker.com/u/outcoldman/splunk/). This is the recommended method of installation as it is easier to update image. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull outcoldman/splunk:6.4.0
```

Or you can pull latest version.

```bash
docker pull outcoldman/splunk:latest
```

Alternately you can build the image locally.

```bash
git clone https://github.com/outcoldman/docker-splunk.git
cd docker-splunk/splunk
docker build --tag="$USER/splunk" .
```

## Quick Start

To manually start Splunk Enterprise container 

```bash
docker run --hostname splunk -p 8000:8000 -d --env SPLUNK_START_ARGS="--accept-license" outcoldman/splunk:6.4.0
```

This docker image has two data volumes `/opt/splunk/etc` and `/opt/splunk/var` (See [Data Store](#data-store)). To avoid losing any data when container is stopped/deleted mount these volumes from docker volume containers (see [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/))

```bash
docker run --name vsplunk -v /opt/splunk/etc -v /opt/splunk/var busybox
docker run --hostname splunk --name splunk --volumes-from=vsplunk -p 8000:8000 -d --env SPLUNK_START_ARGS="--accept-license" outcoldman/splunk:6.4.0
```

Or if you use [docker-compose](https://docs.docker.com/compose/)

```
version: "2"

networks:
  logging:
    driver: bridge

services:
  splunk:
    image: outcoldman/splunk:6.4
    hostname: splunk
    environment:
      - SPLUNK_START_ARGS=--accept-license
      - SPLUNK_ENABLE_DEPLOY_SERVER=true
    ports:
      - 8000:8000
      - 8088-8089:8088-8089
    networks:
      - microservices
    volumes:
      - ./data/etc:/opt/splunk/etc
      - ./data/var:/opt/splunk/var
```

## Configuration

### Data Store

This image has two data volumes

* `/opt/splunk/etc` - stores Splunk configurations, including applications and lookups
* `/opt/splunk/var` - stores indexed data, logs and internal Splunk data

### User

Splunk processes are running under `splunk` user.

### Ports

Next ports are exposed

* `8000/tcp` - Splunk Web interface (Splunk Enterprise and Splunk Light)
* `8089/tcp` - Splunk Services (All Splunk products)
* `8191/tcp` - Application KV Store (Splunk Enterprise)
* `9997/tcp` - Splunk Indexing Port (not used by default) (Splunk Enterprise)
* `1514` - Network Input (not used by default) (All Splunk products)
* `8088` - HTTP Event Collector

> We are using `1514` instead of standard `514` syslog port because ports below 
> 1024 are reserved for root access only. See [Run Splunk Enterprise as a different or non-root user](http://docs.splunk.com/Documentation/Splunk/latest/Installation/RunSplunkasadifferentornon-rootuser).

### Entrypoint

You can execute Splunk commands by using

```
docker exec splunk entrypoint.sh splunk version
```

*Splunk is launched in background. Which means that when Splunk restarts (after some configuration changes) - the container will not be affected.*

### Hostname

It is recommended to specify `hostname` for this image, so if you will recreate Splunk instance you will keep the same hostname.

### Basic configuration using Environment Variables

> Some basic configurations are allowed to configure Indexers/Forwarders using
environment variables. For more advanced configurations please use your own
configuration files or deployment server.

- `SPLUNK_ENABLE_DEPLOY_SERVER='true'` - enable deployment server on Indexer.
    - Available: *splunk* image only.
- `SPLUNK_DEPLOYMENT_SERVER='<servername>:<port>` - [configure deployment
    client](http://docs.splunk.com/Documentation/Splunk/latest/Updating/Configuredeploymentclients).
    Set deployment server url.
    - Example: `--env SPLUNK_DEPLOYMENT_SERVER='splunkdeploymentserver:8089'`.
    - Available: *splunk* and *forwarder* images only.
- `SPLUNK_ENABLE_LISTEN=<port>` - enable [receiving](http://docs.splunk.com/Documentation/Splunk/latest/Forwarding/Enableareceiver).
    - Additional configuration is available using `SPLUNK_ENABLE_LISTEN_ARGS`
        environment variable.
    - Available: *splunk* and *light* images only.
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
    - Available: *splunk* and *forwarder* images only.
- `SPLUNK_ADD='<monitor|add> <what_to_monitor|what_to_add>'` - execute add command,
    for example to [monitor files](http://docs.splunk.com/Documentation/Splunk/latest/Data/MonitorfilesanddirectoriesusingtheCLI)
    or [listen](http://docs.splunk.com/Documentation/Splunk/latest/Data/Monitornetworkports) on specific ports.
    - Additional add commands can be executed (up to 30) using
        `SPLUNK_ADD_<1..30>`.
    - Example `--env SPLUNK_ADD='udp 1514' --env SPLUNK_ADD_1='monitor /var/log/*'`.
    - Available: all images.
- `SPLUNK_CMD='any splunk command'` - execute any splunk command.
    - Additional commands can be executed (up to 30) using
        `SPLUNK_CMD_<1..30>`.
    - Example `--env SPLUNK_CMD='edit user admin -password random_password -role
        admin -auth admin:changeme'`.
- `SPLUNK_START_ARGS='--accept-license"` - Splunk requires you to accept the
  license, I (maintainer of this image) don't want do that for you, so please
  add this on your own or start container with `-it` switch.

#### Example

> This is just a simple example to show how configuration works, do not consider
> it as a *best practice* example.

```
> echo "Creating docker network, so all containers will see each other"
> docker network create splunk
> echo "Starting deployment server for forwarders"
> docker run -d --net splunk \
    --hostname splunkdeploymentserver \
    --name splunkdeploymentserver \
    --publish 8000 \
    --env SPLUNK_ENABLE_DEPLOY_SERVER=true \
    --env SPLUNK_START_ARGS="--accept-license" \
    outcoldman/splunk
> echo "Starting indexer 1"
> docker run -d --net splunk \
    --hostname splunkindexer1 \
    --name splunkindexer1 \
    --publish 8000 \
    --env SPLUNK_ENABLE_LISTEN=9997 \
    --env SPLUNK_START_ARGS="--accept-license" \
    outcoldman/splunk
> echo "Starging indexer 2"
> docker run --rm --net splunk \
    --hostname splunkindexer2 \
    --name splunkindexer2 \
    --publish 8000 \
    --env SPLUNK_ENABLE_LISTEN=9997 \
    --env SPLUNK_START_ARGS="--accept-license" \
    outcoldman/splunk
> echo "Starting forwarder, which forwards data to 2 indexers by cloning events"
> docker run -d --net splunk \
    --name forwarder \
    --hostname forwarder \
    --env SPLUNK_FORWARD_SERVER='splunkindexer1:9997' \
    --env SPLUNK_FORWARD_SERVER_ARGS='-method clone' \
    --env SPLUNK_FORWARD_SERVER_1="splunkindexer2:9997" \
    --env SPLUNK_FORWARD_SERVER_1_ARGS="-method clone" \
    --env SPLUNK_ADD='udp 1514' \
    --env SPLUNK_DEPLOYMENT_SERVER='splunkdeploymentserver:8089' \
    --env SPLUNK_START_ARGS="--accept-license" \
    outcoldman/splunk:forwarder
```

After that you will be able to forward syslog data to the *udp* port of
container *forwarder* (we do not publish port, so only from internal
containers). You should see all the data on both indexers. Also you should see
forwarder registered with deployment server.

### Native Docker Driver

The Native Docker Driver was announced in Dec 2015 and you can readme more about it at http://blogs.splunk.com/2015/12/16/splunk-logging-driver-for-docker/.

Before configuring a service to run the Native Docker Driver, make sure to setup the Server. 

* Go to Settings -> Data Inputs and create an HTTP Event Collector
 * Follow the form and create it, copying the value of the TOKEN, like `18EDED48-65E1-4E3D-B47C-C2F14675A6C7`.
* Go to Settings -> Data Inputs -> Http Event Collector -> Global Settings
 * Toggle "All Tokens" to "Enable"
 * Disable the Checkbox "Enable SSL"
 * Notice that the collector port is 8088
* Edit the Source Type of the Token created to your application. For instance, if we start Nginx as shown below, choose "web"

With those settings, you will successfully start a Docker container using the Native Drivers. That is, no more Splunk Forwarders! For instance, suppose you want to start an Nginx container.

```
version: '2'

services:
  nginx:
    image: nginx
    ports:
      - "80:80"
    logging:
      driver: splunk
      options:
        splunk-url: "http://localhost:8088"
        splunk-token: "18EDED48-65E1-4E3D-B47C-C2F14675A6C7"
```

You can verify the current services running as follows:

```
$ docker ps 
CONTAINER ID        IMAGE                   COMMAND                  CREATED              STATUS              PORTS                                                                                    NAMES
39d4cfa83146        nginx                   "nginx -g 'daemon off"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp, 443/tcp                                                              microservices_nginx_1
8c4ade90c02e        outcoldman/splunk:6.4   "/sbin/entrypoint.sh "   55 minutes ago       Up 55 minutes       0.0.0.0:8000->8000/tcp, 1514/tcp, 8191/tcp, 9997/tcp, 0.0.0.0:8088-8089->8088-8089/tcp   logging_splunk_1
```

Make calls to the web server and make sure it will show up in Splunk!!! Automatically!

```
~/dev/github/intuit/servicesplatform-tools/microservices ⌚ 23:54:27
$ curl localhost/      
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

~/dev/github/intuit/servicesplatform-tools/microservices ⌚ 23:54:31
$ curl localhost/perfect
<html>
<head><title>404 Not Found</title></head>
<body bgcolor="white">
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.9.15</center>
</body>
</html>
```

![Image](http://s32.postimg.org/3y5gc69xh/Screen_Shot_2016_05_06_at_11_57_09_PM.png)

## Upgrade from previous version

Upgrade example below

```
# Use data volume container to persist data between upgrades
docker run --name vsplunk -v /opt/splunk/etc -v /opt/splunk/var busybox
# Start old version of Splunk Enterprise
docker run --hostname splunk --name splunk --volumes-from=vsplunk -p 8000:8000 -d --env SPLUNK_START_ARGS="--accept-license" outcoldman/splunk:6.3.3
# Stop Splunk Enterprise container
docker stop splunk
# Remove Splunk Enterprise container
docker rm -v splunk
# Start Splunk Enterprise container with new version
docker run --hostname splunk --name splunk --volumes-from=vsplunk -p 8000:8000 -d --env SPLUNK_START_ARGS="--accept-license" outcoldman/splunk:6.4.0
```
