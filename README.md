# Csimeu Package Manager (CPM)

CLI for csimeu

## Global variables

```bash
# file cpm_env

AUTHOR=${AUTHOR:-csimeu}
# CONFIG_DIR=${CONFIG_DIR:-"/opt/config"}
WWW=${WWW:-"/var/www"}
# DEVEL_PATH=${DEVEL_PATH:-"/var/www"}
WEB_HOME=${WEB_HOME:-"/var/www/html"}
GROUP_ADMIN=
GIT_DOMAIN=${GIT_DOMAIN:-"github.com"}
```

## USER
cpm user:add --help
cpm user:update --help


## Git

- Retrieve repository name from git url `cpm git:repo:name [git_remote]`

```bash
cpm git:repo:name https://github.com/csimeu/cli.git
cpm git:repo:name git@github.com:csimeu/cpm.git
cpm git:repo:name /csimeu/cpm.git
```

- Checks existance of git repository `cpm git:exists [git_remote]`

```bash
cpm git:exists https://github.com/csimeu/cpm.git
cpm git:exists git@github.com:csimeu/cpm.git
cpm git:exists /csimeu/cpm.git
```

- Clone a repository `cpm git:clone <git_remote> </path/of/library> [-b|--branch=<branch_name>]`

- Update local repository `cpm git:update </path/of/library>`

## Utils functions

- Transform snake words to camel `cpm snake:to:camel enter_your_text1 enter_your_text2`
- Transform camel words to snake `cpm camel:to:snake EnterYourText1 EnterYourText2`
- Checks if given string is an valid url `cpm is:url https://google.com`

## Troubleshoots

fix bad interpreter: sed -i -e 's/\r$//' scriptname.sh

## Comcat bash script in single file

    /workplace/infra/bash/build_cpm /workplace/infra/bash/src/ /workplace/infra/bash/cpm


## Applications

### Elasticsearch, logstach, Kibana

```bash
# Mettre à jour le cpm
cpm self-update

# install elk
cpm elk:install --version=7 --beats
cpm elk:install:beats

# httpd
cpm httpd:install

# php
cpm php:install 56-php
```

### Mysql

```bash
# 
cpm mysql:init --user=$DB_USER --password=$DB_PASSWORD
```

### Postgresql

```bash
# Setup the database
cpm postgresql:setup

# Create user
cpm postgresql:createuser --db-user=gitlab --db-password=gitlab123
cpm postgresql:createdb --db-name=gitlab --db-user=gitlab

```

### 

```bash
```

### 

```bash
```