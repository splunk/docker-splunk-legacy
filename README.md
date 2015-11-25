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
- [Data Store](#upgrade-from-previous-version)

## Supported tags

Current branch:

* `6.1`, `6.1.8` - Splunk Enterprise
* `6.1-forwarder`, `6.1.8-forwarder` - Splunk Universal Forwarder

For previous versions or newest releases see other branches.

## Introduction

Dockerfiles to build [Splunk](https://splunk.com) including Enterpise and Universal Forwarder.

> Examples below show you how to pull and start Splunk Enterprise. If you want to use Splunk Universal Forwarder - you just need to change tags to add `-forwarder` and use `universalforwarder` folders.

### Version

* Version: `6.1.8`
* Build: `266909`

## Installation

Pull the image from the [docker registry](https://registry.hub.docker.com/u/outcoldman/docker-splunk/). This is the recommended method of installation as it is easier to update image. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull outcoldman/splunk:6.2.4
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
docker run --hostname splunk -p 8000:8000 -d outcoldman/splunk:6.2.4
```

This docker image has two data volumes `/opt/splunk/etc` and `/opt/splunk/var` (See [Data Store](#data-store)). To avoid losing any data when container is stopped/deleted mount these volumes from docker volume containers (see [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/))

```bash
docker run --name vsplunk -v /opt/splunk/etc -v /opt/splunk/var busybox
docker run --hostname splunk --name splunk --volumes-from=vsplunk -p 8000:8000 -d outcoldman/splunk:6.2.4
```

Or if you use [docker-compose](https://docs.docker.com/compose/)

```
vsplunk:
  image: busybox
  volumes:
    - /opt/splunk/etc
    - /opt/splunk/var

splunk:
  image: outcoldman/splunk:6.2.4
  hostname: splunk
  volumes_from:
    - vsplunk
  ports:
    - 8000:8000
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

* `8000/tcp` - Splunk Web interface (Splunk Enterprise)
* `8089/tcp` - Splunk Services (All Splunk products)
* `9997/tcp` - Splunk Indexing Port (not used by default) (Splunk Enterprise)
* `514/udp` - Network Input (not used by default) (All Splunk products)

### Entrypoint

You can execute Splunk commands by using

```
docker exec splunk entrypoint.sh splunk version
```

*Splunk is launched in background. Which means that when Splunk restarts (after some configuration changes) - the container will not be affected.*

### Hostname

It is recommended to specify `hostname` for this image, so if you will recreate Splunk instance you will keep the same hostname.

## Upgrade from previous version

Upgrade example below

```
# Use data volume container to persist data between upgrades
docker run --name vsplunk -v /opt/splunk/etc -v /opt/splunk/var busybox
# Start old version of Splunk Enterprise
docker run --hostname splunk --name splunk --volumes-from=vsplunk -p 8000:8000 -d outcoldman/splunk:6.2.3
# Stop current Splunk Enterprise
docker exec splunk entrypoint.sh splunk stop
# Kill Splunk Enterprise container
docker kill splunk
# Remove Splunk Enterprise container
docker rm -v splunk
# Start Splunk Enterprise container with new version
docker run --hostname splunk --name splunk --volumes-from=vsplunk -p 8000:8000 -d outcoldman/splunk:6.2.4
```
