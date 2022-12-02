#!/bin/bash


nodejs_install() {
    local appName="nodejs npm yarn"
    
    case `plateform` in 
        alpine) install nodejs npm yarn ;;
        redhat)
            if [ ! -f /etc/yum.repos.d/yarn.repo ]
            then
                curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
            fi
            install nodejs npm yarn
            sudo npm install -g n && sudo /usr/local/bin/n lts
            ;;
        debian|ubuntu)
            install nodejs npm node-gyp yarn
            sudo npm install -g n && sudo /usr/local/bin/n lts
        ;;
    esac

    # sudo npm install -g n && sudo /usr/local/bin/n lts

    # echo "---> npm install -g npm@latest"
    # # npm install -g npm@latest

    # echo "---> npm install --global 
    # npm install --global @angular/cli@latest
    
    echo ">> Installed applications '$appName' "
}

