# Overview

Setup docker-compose.

### Install

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### Run the geminabox docker container

```bash
docker run -d -p 9292:9292 --name geminabox spoonest/geminabox:latest
```

### Install the geminabox gem

```bash
gem install geminabox
```

### Build and deploy gem to gem server

```bash
cd shatterdome
rake gem:build gem:deploy gem:install
```
