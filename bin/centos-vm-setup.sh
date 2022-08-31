#!/bin/bash


## Install cpm (cenr package manager)

# CENR_HOME=${1:-$HOME}
CENR_HOME=${CENR_HOME:-/opt/cenr}
CPM_HOME=$CENR_HOME/cpm-cli
sudo mkdir -p $CPM_HOME

OS_PLATEFORM_NAME=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
OS_PLATEFORM_VERSION=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release)

sudo sed -i -e "/^OS_PLATEFORM_NAME=.*/d" /etc/environment
sudo sed -i -e "/^OS_PLATEFORM_VERSION=.*/d" /etc/environment

sudo tee -a /etc/environment << EOF > /dev/null
OS_PLATEFORM_NAME=$OS_PLATEFORM_NAME
OS_PLATEFORM_VERSION=$OS_PLATEFORM_VERSION
EOF

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
	pod = push origin devel
	pos = push origin staging
	pom = push origin master
	poh = push origin HEAD
	pogm = !git push origin gh-pages && git checkout master && git pull origin master && git rebase gh-pages && git push origin master && git checkout gh-pages
	pomg = !git push origin master && git checkout gh-pages && git pull origin gh-pages && git rebase master && git push origin gh-pages && git checkout master
	plo = pull origin
	plod = pull origin devel
	plos = pull origin staging
	plom = pull origin master
	ploh = pull origin HEAD
	unstage = reset --hard HEAD^
	last = log -1 HEAD
	ls = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]" --decorate
	ll = log --pretty=format:"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]" --decorate --numstat
	f = "!git ls-files | grep -i"
	gr = grep -Ii
	la = "!git config -l | grep alias | cut -c 7-"
EOF

## admin-user setup 
tee $CPM_HOME/bin/vm-admin-setup.sh << EOF > /dev/null
#!/bin/bash

ADMIN_USER=\${1:-\$ADMIN_USER}
ADMIN_USER=\${ADMIN_USER:-cenadm}

sudo sed -i -e "/^ADMIN_USER=.*/d" /etc/environment
sudo tee -a /etc/environment << FIN > /dev/null
ADMIN_USER=\$ADMIN_USER
FIN

## Install cenadm account
sudo useradd \$ADMIN_USER
sudo usermod -aG \$ADMIN_USER $OS_PLATEFORM_NAME
sudo usermod -aG $OS_PLATEFORM_NAME \$ADMIN_USER
sudo usermod -aG wheel \$ADMIN_USER
sudo mkdir -p /home/\$ADMIN_USER/.ssh/
sudo chown \$ADMIN_USER:\$ADMIN_USER -R /home/\$ADMIN_USER/.ssh/
sudo chmod 600 -R /home/\$ADMIN_USER/.ssh/
sudo chmod 700 /home/\$ADMIN_USER/.ssh/
sudo tee /etc/sudoers.d/admin-init << FIN > /dev/null
# User rules for \$ADMIN_USER
%\$ADMIN_USER ALL=(ALL) 	ALL
%\$ADMIN_USER ALL=NOPASSWD:/usr/sbin/service
%\$ADMIN_USER ALL=(apache) NOPASSWD:ALL
FIN

sudo usermod -aG docker \$ADMIN_USER
sudo usermod -aG docker $OS_PLATEFORM_NAME
EOF

sudo chmod +x $CPM_HOME/bin/vm-admin-setup.sh

## hostname setup 
tee $CPM_HOME/bin/vm-hostname-setup.sh << EOF > /dev/null
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

tee $CPM_HOME/bin/vm-add-extrahosts.sh << EOF > /dev/null
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

tee $CPM_HOME/bin/vm-setup.sh << EOF > /dev/null
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

sudo yum install -y initscripts \
  rsync openssh-server telnet \
  rsyslog gnupg gcc-c++ \
  curl wget vim git sudo nano cifs-utils \
  unzip bzip2 zip tmux \
  tree zsh net-tools bash-completion crontabs passwd cracklib-dicts \
  nfs-utils nfs4-acl-tools httpd-tools bind-utils \
  lvm2 firewalld

sudo yum -y install gdal gdal-devel

# Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
source /etc/bash_completion.d/docker-compose

# Python
sudo yum install -y python3-pip
sudo pip3 install --upgrade pip
# sudo pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U


$CPM_HOME/bin/vm-hostname-setup.sh \$INSTANCE_ENV \$INSTANCE_NAME \$INFRA_NAME \$INFRA_DOMAIN \$INFRA_EXTERNAL_DOMAIN
$CPM_HOME/bin/vm-add-extrahosts.sh
$CPM_HOME/bin/vm-admin-setup.sh


# sudo chown :\$ADMIN_USER -R /opt/cenr
sudo chmod g+w -R /opt/cenr

sudo yum update -y
git config --global http.sslVerify false

echo ">>>>>>>> END <<<<<<<<<"
EOF


sudo chmod +x $CPM_HOME/bin/*.sh

if [ $# -gt 0 ]; then
  vm-setup.sh $@
fi
