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
        alpine) 
            install nodejs npm g++
            install libc6-compat
            ;;
        redhat)
            if [ ! -f /etc/yum.repos.d/yarn.repo ]
            then
                curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
            fi
            install nodejs npm gcc-c++
            # sudo npm install -g n && sudo /usr/local/bin/n $version
            ;;
        debian|ubuntu)
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
            install nodejs
            # # curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            # # echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt-get update
            # sudo apt-get install yarn -y
            echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
        ;;
    esac

    if [ "$(plateform)" != "alpine" ]; then
        sudo npm install -g n && sudo /usr/local/bin/n $version
        echo "---> npm install -g npm@$npm_version"
        sudo npm install -g npm@$npm_version
    fi

    echo "---> npm install --global @angular/cli@$ng_version"
    sudo npm install --global @angular/cli@$ng_version

    echo "---> npm install --global pnpm turbo yarn"
    sudo npm install --global pnpm turbo yarn

    echo ">> Installed applications '$appName' "
}
