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
# install elk
cpm elk:install --version=7 --beats
cpm elk:install:beats

# httpd
cpm httpd:install
```

```bash
```