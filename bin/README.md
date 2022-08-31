# setup infrastructure

Executer les commandes suivantes pour la configuration de la VM

```sh

echo "198.168.187.137 atelier-cen.cen.umontreal.ca" | sudo tee -a /etc/hosts

CENR_HOME=$HOME
mkdir -p $CENR_HOME/infra-cli $CENR_HOME/.bashrc.d

tee $CENR_HOME/.bashrc.d/infra-cli.rc << EOF > /dev/null

if ! [[ "\$PATH" =~ "$CENR_HOME/infra-cli:" ]]
then
    PATH="$CENR_HOME/infra-cli:\$PATH"
fi

alias setup-vm="cd ${CENR_HOME}/infra-cli && git pull origin master && $(awk -F= '/^ID=/{print $2}' /etc/os-release)-vm-setup.sh"
alias infra-cli-update="cd ${CENR_HOME}/infra-cli && git pull origin master"
export PATH 
EOF

chmod +x $CENR_HOME/.bashrc.d/*
# chown $(awk -F= '/^ID=/{print $2}' /etc/os-release):$(awk -F= '/^ID=/{print $2}' /etc/os-release) -R $CENR_HOME/infra-cli
sudo yum install -y git
git config --global http.sslVerify false
git clone https://gitlab:LyvB5aDnksGeWtTiyFdP@atelier-cen.cen.umontreal.ca/gitlab/atelier-cen/infra-cli.git $CENR_HOME/infra-cli

setup-vm $env $name $project $domain


```

example: setup-vm prod base fedora belga-cloud
