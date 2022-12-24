#!/bin/bash


nodejs_install() {
    local appName="nodejs npm yarn"

    local version=lts
    local npm_version=latest
    local ng_version=latest
    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    
    case `plateform` in 
        alpine) install nodejs npm yarn g++;;
        redhat)
            if [ ! -f /etc/yum.repos.d/yarn.repo ]
            then
                curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
            fi
            install nodejs npm yarn gcc-c++
            # sudo npm install -g n && sudo /usr/local/bin/n $version
            ;;
        debian|ubuntu)
            install nodejs npm node-gyp yarn build-essential
            # sudo npm install -g n && sudo /usr/local/bin/n $version
        ;;
    esac

    sudo npm install -g n && sudo /usr/local/bin/n $version

    echo "---> npm install -g npm@$npm_version"
    sudo npm install -g npm@$npm_version

    echo "---> npm install --global @angular/cli@$ng_version"
    sudo npm install --global @angular/cli@$ng_version
    
    echo ">> Installed applications '$appName' "
}

