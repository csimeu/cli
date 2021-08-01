#!/bin/bash


nodejs_install() {
    local appName="nodejs npm yarn"
    
    case `plateform` in 
        redhat)
            if [ ! -f /etc/yum.repos.d/yarn.repo ]
            then
                curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
            fi
            ;;
        # debian)
        # ;;
    esac

    install -y nodejs npm
    npm install -g n && n stable

    # echo "---> npm install -g npm@latest"
    # # npm install -g npm@latest
    
    echo "---> npm install --global yarn"
    npm install --global yarn
    # npm install --global @angular/cli@latest
    
    echo ">> Installed applications '$appName' "
}

