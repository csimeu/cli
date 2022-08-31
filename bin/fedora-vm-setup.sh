#!/bin/bash


## Install cpm (cenr package manager)

# CENR_HOME=${1:-$HOME}
CENR_HOME=${CENR_HOME:-$HOME}
sudo mkdir -p $CENR_HOME/infra-cli 

OS_PLATEFORM_NAME=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
OS_PLATEFORM_VERSION=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release)

sudo sed -i -e "/^OS_PLATEFORM_NAME=.*/d" /etc/environment
sudo sed -i -e "/^OS_PLATEFORM_VERSION=.*/d" /etc/environment

sudo tee -a /etc/environment << EOF > /dev/null
OS_PLATEFORM_NAME=$OS_PLATEFORM_NAME
OS_PLATEFORM_VERSION=$OS_PLATEFORM_VERSION
EOF

tee $CENR_HOME/infra-cli/cenr-cli-install.sh << EOF > /dev/null
#!/bin/bash

CS_HOME=\${1:-/opt/cenr/cenr-cli}
sudo rm -rf \${CS_HOME}
sudo mkdir -p \${CS_HOME}
# sudo git clone https://github.com/csimeu/cli.git \${CS_HOME}
sudo git clone https://atelier-cen.cen.umontreal.ca/gitlab/cenr/cenr-cli.git \${CS_HOME}

sudo tee /etc/profile.d/cenr-cli.sh << FIN > /dev/null
#!/bin/bash

source /etc/environment

if ! [[ "\\\$PATH" =~ "\${CS_HOME}/bin:" ]]
then
    PATH="\${CS_HOME}/bin:\\\$PATH"
fi
export PATH=\\\$PATH OS_PLATEFORM_NAME OS_PLATEFORM_VERSION
alias vi=vim

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

if [ -d \${CS_HOME}/env ];
then
  for file in \${CS_HOME}/env/*
  do 
    source \\\$file
  done
fi
FIN
EOF

sudo chmod +x $CENR_HOME/infra-cli/cenr-cli-install.sh

sudo tee /etc/gitconfig << EOF > /dev/null
[http]
    sslVerify = false
[alias]
    co = checkout
    cob = checkout -b
    coo = !git fetch && git checkout
    br = branch
    brd = branch -d
    brD = branch -D
    merged = branch --merged
    st = status
    aa = add -A .
    com = commit -a -m
    aacm = !git add -A . && git commit -m
    cp = cherry-pick
    amend = commit --amend
    devel = !git checkout devel && git pull origin devel
    staging = !git checkout staging && git pull origin staging
    master = !git checkout master && git pull origin 
    po = push origin
    pop = push origin prod
    pod = push origin devel
    pos = push origin staging
    pom = push origin master
    plo = pull origin
    plop = pull origin prod
    plod = pull origin devel
    plos = pull origin staging
    plom = pull origin master
    ploh = pull origin HEAD
    pogm = !git push origin gh-pages && git checkout master && git pull origin master && git rebase gh-pages && git push origin master && git checkout gh-pages
    pomg = !git push origin master && git checkout gh-pages && git pull origin gh-pages && git rebase master && git push origin gh-pages && git checkout master
    unstage = reset --hard HEAD^
    last = log -1 HEAD
    ls = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]" --decorate
    ll = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]" --decorate --numstat
    f = "!git ls-files | grep -i"
    gr = grep -Ii
    la = "!git config -l | grep alias | cut -c 7-"
    #
    pa = push atelier
    pap = push atelier prod
    pad = push atelier devel
    pas = push atelier staging
    pam = push atelier master
    pah = push atelier HEAD
    pla = pull atelier
    plap = pull atelier prod
    plad = pull atelier devel
    plas = pull atelier staging
    plam = pull atelier master
    plah = pull atelier HEAD
EOF

## admin-user setup 
tee $CENR_HOME/infra-cli/vm-admin-setup.sh << EOF > /dev/null
#!/bin/bash

ADMIN_USER=\${1:-\$ADMIN_USER}
ADMIN_USER=\${ADMIN_USER:-cenadm}

sudo sed -i -e "/^ADMIN_USER=.*/d" /etc/environment
sudo tee -a /etc/environment << FIN > /dev/null
ADMIN_USER=\$ADMIN_USER
FIN

## Install cenadm account
sudo useradd \$ADMIN_USER
# sudo usermod -aG wheel \$ADMIN_USER
sudo usermod -aG docker \$ADMIN_USER
sudo mkdir -p /home/\$ADMIN_USER/.ssh/
sudo tee /home/\$ADMIN_USER/.ssh/authorized_keys << FIN > /dev/null
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7jr04YsgUiUPxuD7hH0fWS7GrUIu4n4/7H+31g9TuccG9mlP9RWNt1dBMHBBByjE/MeSjt5cR/RWMD7CNhFSqoYs0P7efmS8OhCX5VJbz7GQno1a1CCygElPZOe8LHMTR1bBBQ+Q5dTXpR3l16JmGyk2FkWgZXcme65S84DWDvo4m55gjDCdBLDcfcupOiYwZzgZoujYYIQlimzvZrtbBRFvcKphUqMuvfEDR3kEbx0nOJGelLn3s1ClOCSUNA+bRZdaB5+Ud6Hor48PmuEuVnHQjiOchSX1mdsRBzPqQUhnX4/z8PLnnt1lvz/30q9Je8dZX1pGPjcvgg71dn/KCCTEbbvWezqD/ftIppU0SSohf5oL9tNfGu2AyI8AjhArA9T0jYoidNRZrZpmR59FYVJThR3Vk0vnsxPykEi4c2SkXVM1tit/ha5rp5icL8DZbvFi7Pi9oVYd2czZgmjxb9EdcJO8/3r8TnSTCt3n1BJDTJkYsoW4rc4wb4wACrD6ylaq6FSxMTjq9gQM6nR898CvGRtzZMIHQ01NU9SKtTR+xGLjCkZO7qOlbHLN1qpa85TEVhZINP5JIvlcas/xJzrg5guHnED1Jsi+/doCU+/OzAl5p8mbwrm7oDV0Tdgd3BQD/GNuJjDvZhjw5mnIiW1/uDdFte6ypFjTNeKRDvQ== cenadm@umontreal.ca
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT8vT6WNt8D+vvX76FRtsuQASrJcCGgus8QKeJXSMVYOd02TlmTtwMZ2KLwrcwT5Xpp/IgRDgUPF4SeahvShPYGjAs9AtAMPHFcqP4IFdAGwci74ES0/Yn74IuPQ4CkF2jB5zkOUo4FXluD61FrGpyLdD/c/sdUHKeBzaJq9sBE1lZu+/S3LVX1YtgPI+PDSkiIPmbpevADbOVgKrMn9yQDLZwo/fSfl0iDvD5J73QhojM3wZDIKuymR0kIYAxnCuZK7mdGYG7o/hXLgHKrxBUgx8vKBLHaX4ObUyBQHgXv6x+gttcTp8OH0w3PLJPmbFrrXh6RLb0DhXudzmJkwNT christian.kamgang.simeu@umontreal.ca
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlYJPUZk9S3POrDWKqK9y+ZvETibMJxM9r5QmUjAbe1AsVfysr6JnBlqg/sdIWNHLp7WNMbWXtTgddNWFjJpcPBxVC62OXloNHoM0DIEzQ242MwKYSFlbZMXeh7y9sh5M/vggZ5FmLB0X1MIOGnTBX+7UJoWLHMZ2BxybZbLQjyiTWR+AO+Fr5VMz7tdcSEzXEv5ZdbyYv294OesAqquRy5pQeDQvhLG3o+4VuT/9BI/JFcfv/4L8cKjyWGPHZ5PKmzewmnq3HhSUnZuTu0Io5C9v3UDeVhi+AzZbEsl9eqjVKhU1E93BUAxI/dIbvXQebjwuC3CR4yYLVlmVjPTMZw== luc.grondin@umontreal.ca
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+DXnVWEejLpROErVA1jKTEnhY53kRoPpnMQCn5LDC+ christian.kamgang.simeu@umontreal.ca ed25519 key
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDxfUBXOdZmTsLk3jrpkICQrt7o2NEXSXCOjaY9iocy \$ADMIN_USER
FIN

sudo tee /home/\$ADMIN_USER/.ssh/id_ed25519 << FIN > /dev/null
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBQ8X1AVznWZk7C5N466ZCAkK7e6NjRF0lwjo2mPYqHMgAAAKCJPgawiT4G
sAAAAAtzc2gtZWQyNTUxOQAAACBQ8X1AVznWZk7C5N466ZCAkK7e6NjRF0lwjo2mPYqHMg
AAAECFtvGaF+VO828EgikIyziJqsZab4ksJ95KWy5cx7No7VDxfUBXOdZmTsLk3jrpkICQ
rt7o2NEXSXCOjaY9iocyAAAAG2NlbmFkbUBjaHVwaW5qLmJlbHVnYS1jbG91ZAEC
-----END OPENSSH PRIVATE KEY-----
FIN

sudo chown \$ADMIN_USER:\$ADMIN_USER -R /home/\$ADMIN_USER/.ssh/
sudo chmod 600 -R /home/\$ADMIN_USER/.ssh/
sudo chmod 700 /home/\$ADMIN_USER/.ssh/

sudo tee /etc/sudoers.d/admin-init << FIN > /dev/null
# User rules for \$ADMIN_USER
%\$ADMIN_USER ALL=(ALL) 	ALL
%\$ADMIN_USER ALL=NOPASSWD:/usr/sbin/service
%\$ADMIN_USER ALL=(apache) NOPASSWD:ALL
FIN

EOF

sudo chmod +x $CENR_HOME/infra-cli/vm-admin-setup.sh

## hostname setup 
tee $CENR_HOME/infra-cli/vm-hostname-setup.sh << EOF > /dev/null
#!/bin/bash

INSTANCE_ENV=\${1:-\$INSTANCE_ENV}
INSTANCE_NAME=\${2:-\$INSTANCE_NAME}
INFRA_NAME=\${3:-\$INFRA_NAME}
INFRA_DOMAIN=\${4:-\$INFRA_DOMAIN}
INFRA_DOMAIN=\${INFRA_DOMAIN:-beluga-cloud}
INFRA_EXTERNAL_DOMAIN=\${5:-\$INFRA_EXTERNAL_DOMAIN}
INFRA_EXTERNAL_DOMAIN=\${INFRA_EXTERNAL_DOMAIN:-"\$INFRA_NAME.\$INFRA_DOMAIN"}

HOSTNAME="\$INSTANCE_NAME.\$INFRA_NAME.\$INFRA_DOMAIN"
echo "--> setting hostname as \"\$INSTANCE_NAME.\$INFRA_NAME.\$INFRA_DOMAIN\""
sudo hostnamectl set-hostname "\$INSTANCE_NAME.\$INFRA_NAME.\$INFRA_DOMAIN"

sudo sed -i -e "/^INSTANCE_NAME=.*/d" /etc/environment
sudo sed -i -e "/^INSTANCE_ENV=.*/d" /etc/environment
sudo sed -i -e "/^INFRA_NAME=.*/d" /etc/environment
sudo sed -i -e "/^INFRA_DOMAIN=.*/d" /etc/environment
sudo sed -i -e "/^INFRA_EXTERNAL_DOMAIN=.*/d" /etc/environment

sudo tee -a /etc/environment << FIN > /dev/null
#
INSTANCE_NAME=\$INSTANCE_NAME
INSTANCE_ENV=\$INSTANCE_ENV
INFRA_NAME=\$INFRA_NAME
INFRA_DOMAIN=\$INFRA_DOMAIN
INFRA_EXTERNAL_DOMAIN=\$INFRA_EXTERNAL_DOMAIN

FIN

EOF

tee $CENR_HOME/infra-cli/vm-add-extrahosts.sh << EOF > /dev/null
sudo sed -i -e "/$HOSTNAME\$/d" /etc/environment
sudo sed -i -e "/atelier-cen.cen.umontreal.ca\$/d" /etc/environment
sudo sed -i -e "/registry-cen.cen.umontreal.ca\$/d" /etc/environment
sudo sed -i -e "/monitoring-cen.cen.umontreal.ca\$/d" /etc/environment
sudo sed -i -e "/elastic-cen.cen.umontreal.ca\$/d" /etc/environment
sudo sed -i -e "/fleet-cen.cen.umontreal.ca\$/d" /etc/environment

## hostname
sudo tee -a /etc/hosts << FIN > /dev/null
127.0.0.1 $HOSTNAME
198.168.187.137 atelier-cen.cen.umontreal.ca
198.168.187.137 registry-cen.cen.umontreal.ca
198.168.187.137 monitoring-cen.cen.umontreal.ca
198.168.187.137 elastic-cen.cen.umontreal.ca
198.168.187.137 fleet-cen.cen.umontreal.ca
FIN
EOF

tee $CENR_HOME/infra-cli/vm-setup-environment.sh << EOF > /dev/null
GIT_USER_PASSWORD=\${GIT_USER_PASSWORD:-"gitlab:LyvB5aDnksGeWtTiyFdP"}
GIT_DOMAIN=\${GIT_DOMAIN:-"atelier-cen.cen.umontreal.ca"}
GIT_BASE_PATH=\${GIT_BASE_PATH:-"/gitlab"}
GIT_DEFAULT_URL=\${GIT_DEFAULT_URL:-"https://\$GIT_USER_PASSWORD@\$GIT_DOMAIN\$GIT_BASE_PATH/"}
GIT_DEFAULT_REPOSITORIES=\${GIT_DEFAULT_REPOSITORIES}

#
sudo sed -i -e "/^GIT_USER_PASSWORD=.*/d" /etc/environment
sudo sed -i -e "/^GIT_DOMAIN=.*/d" /etc/environment
sudo sed -i -e "/^GIT_BASE_PATH=.*/d" /etc/environment
sudo sed -i -e "/^GIT_DEFAULT_URL=.*/d" /etc/environment
sudo sed -i -e "/^GIT_DEFAULT_REPOSITORIES=.*/d" /etc/environment


sudo tee -a /etc/environment << FIN > /dev/null
GIT_DOMAIN=\$GIT_DOMAIN
GIT_BASE_PATH=\$GIT_BASE_PATH
GIT_USER_PASSWORD=\$GIT_USER_PASSWORD
GIT_DEFAULT_URL=\$GIT_DEFAULT_URL
GIT_DEFAULT_REPOSITORIES=\$GIT_DEFAULT_REPOSITORIES
FIN

sudo sed -i -e '/^\(GIT_USER_PASSWORD\|GIT_DOMAIN\|GIT_BASE_PATH\|GIT_DEFAULT_URL\|GIT_DEFAULT_REPOSITORIES\)=/d' /etc/profile.d/environment.sh
source /etc/environment && sudo tee -a /etc/profile.d/environment.sh << FIN > /dev/null
export GIT_USER_PASSWORD=\$GIT_USER_PASSWORD
export GIT_DOMAIN=\$GIT_DOMAIN
export GIT_BASE_PATH=\$GIT_BASE_PATH
export GIT_DEFAULT_URL=\$GIT_DEFAULT_URL
export GIT_DEFAULT_REPOSITORIES=\$GIT_DEFAULT_REPOSITORIES
FIN


EOF

tee $CENR_HOME/infra-cli/vm-setup.sh << EOF > /dev/null
#!/bin/bash

ENV_FILE=\${1}
if [ -n "\$ENV_FILE" ] ; 
then 
  if [ -f "\$ENV_FILE" ] ; then source \$ENV_FILE ; fi
fi

sudo touch /etc/environment

INSTANCE_ENV=\${1:-\$INSTANCE_ENV}
INSTANCE_NAME=\${2:-\$INSTANCE_NAME}
INFRA_NAME=\${3:-\$INFRA_NAME}
INFRA_DOMAIN=\${4:-\$INFRA_DOMAIN}
INFRA_DOMAIN=\${INFRA_DOMAIN:-beluga-cloud}
INFRA_EXTERNAL_DOMAIN=\${5:-\$INFRA_EXTERNAL_DOMAIN}
INFRA_EXTERNAL_DOMAIN=\${INFRA_EXTERNAL_DOMAIN:-"\$INFRA_NAME.\$INFRA_DOMAIN"}


sudo tee /etc/yum.repos.d/docker-ce.repo << FIN > /dev/null
[docker-ce-stable]
name=Docker CE Stable - \\\$basearch
baseurl=https://download.docker.com/linux/$OS_PLATEFORM_NAME/$OS_PLATEFORM_VERSION/\\\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/$OS_PLATEFORM_NAME/gpg
FIN

sudo dnf install -y http://rpms.remirepo.net/$OS_PLATEFORM_NAME/remi-release-$OS_PLATEFORM_VERSION.rpm

sudo dnf install -y initscripts \
  rsync openssh-server telnet \
  rsyslog gnupg gcc-c++ \
  curl wget vim git sudo nano cifs-utils \
  unzip bzip2 zip tmux \
  tree zsh net-tools bash-completion crontabs passwd cracklib-dicts \
  nfs-utils nfs4-acl-tools httpd-tools bind-utils \
  lvm2 dnf-plugins-core firewalld

sudo dnf -y install gdal gdal-devel

# Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
source /etc/bash_completion.d/docker-compose

# Python
sudo dnf install -y python3-pip
sudo pip3 install --upgrade pip
# sudo pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U


$CENR_HOME/infra-cli/vm-hostname-setup.sh \$INSTANCE_ENV \$INSTANCE_NAME \$INFRA_NAME \$INFRA_DOMAIN \$INFRA_EXTERNAL_DOMAIN
$CENR_HOME/infra-cli/vm-add-extrahosts.sh
$CENR_HOME/infra-cli/cenr-cli-install.sh
$CENR_HOME/infra-cli/vm-admin-setup.sh


# sudo chown :\$ADMIN_USER -R /opt/cenr
sudo chmod g+w -R /opt/cenr

sudo dnf update -y
git config --global http.sslVerify false

echo ">>>>>>>> END <<<<<<<<<"
EOF


sudo chmod +x $CENR_HOME/infra-cli/*.sh

if [ $# -gt 0 ]; then
  vm-setup.sh $@
fi
