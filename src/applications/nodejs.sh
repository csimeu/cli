#!/bin/bash


nodejs_install() {
    local appName="nodejs npm yarn"
    
    case `plateform` in 
        redhat)
            if [ ! -f /etc/yum.repos.d/yarn.repo ]
            then
                curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
            fi
            install -y nodejs npm yarn
            ;;
        debian)
            install -y nodejs npm node-gyp nodejs-dev libssl1.0-dev yarn
        ;;
    esac

    sudo npm install -g n && sudo /usr/local/bin/n lts

    # echo "---> npm install -g npm@latest"
    # # npm install -g npm@latest

    # echo "---> npm install --global 
    # npm install --global @angular/cli@latest
    
    echo ">> Installed applications '$appName' "
}

