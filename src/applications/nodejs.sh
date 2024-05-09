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
            install nodejs npm node-gyp build-essential
            # fixed https://stackoverflow.com/questions/46013544/yarn-install-command-error-no-such-file-or-directory-install
            # sudo npm install -g yarn
            # sudo npm install -g n && sudo /usr/local/bin/n $version
        ;;
    esac

    if [ "$(plateform)" != "alpine" ]; then
        sudo npm install -g n && sudo /usr/local/bin/n $version

        echo "---> npm install -g npm@$npm_version"
        sudo npm install -g npm@$npm_version

        echo "---> npm install --global @angular/cli@$ng_version"
        sudo npm install --global @angular/cli@$ng_version
    fi

    case `plateform` in
        debian|ubuntu)
            # fixed https://stackoverflow.com/questions/46013544/yarn-install-command-error-no-such-file-or-directory-install
            # sudo npm install -g yarn
            # sudo apt remove -y cmdtest
            # sudo apt remove -y yarn
            curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt-get update
            sudo apt-get install yarn -y
            echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
        ;;
    esac

    echo ">> Installed applications '$appName' "
}
