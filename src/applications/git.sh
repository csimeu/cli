#!/bin/bash
#

is_git_url()
{
    http_regex='(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    ssh_regex='[-A-Za-z0-9_@/.]+:[-A-Za-z0-9\+&@#/%?=~_|!:,.;]'
    path_regex='^/|(/[a-zA-Z0-9_-]+)+$'
    string=$1
    if [[ $string =~ $http_regex ]]
    then 
        true
    elif  [[ $string =~ $ssh_regex ]]
    then
        true
    elif  [[ $string =~ $path_regex ]]
    then
        true
    else
        false
    fi
}

# Reads arguments options
parse_git_arguments()
{
  # if [ $# -ne 0 ]; then
    TEMP=`getopt -o b::,r:: --long branch::,tag::,workspace-dir::,framework::,repo_url::,config-dir::,cache-dir::,logs-dir::,name::,repo::,team::,composer-update,workspace -n "$0" -- "$@"`
    eval set -- "$TEMP"
    # extract options and their arguments into variables.
    while true ; do
        case "$1" in
            # -e|--env) _env=${2:-"$_env"} ; shift 2 ;;
            # -p|--path) _path=${2%"/"} ; shift 2 ;;
            # -u|--user) _user=$2 ; shift 2 ;;
            -b|--branch) _branch=${2:-"$_branch"}; shift 2 ;;
            # --framework) _framework=${2:-"$_framework"}; shift 2 ;;
            # --name) _name+=" ${2:-"$_name"}"; shift 2 ;;
            -r|--repo) _repo+=" ${2:-"$_repo"}"; shift 2 ;;
            # --repo_url) _repo_url=$2; shift 2 ;;
            # --config-dir) _config_dir=$2; shift 2 ;;
            # --cache-dir) _cache_dir=$2; shift 2 ;;
            # --logs-dir) _logs_dir=$2; shift 2 ;;
            # --team) _team=${2:-"$_team"}; shift 2 ;;
            --composer-update) _composer=1; shift 1 ;;
            # --workspace) _is_workspace=1; shift 1 ;;
            --) shift ; break ;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    shift $(expr $OPTIND - 1 )
    _parameters=$@

  # fi
}

# git_branch() {
#     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
# }

##
## Retrieve repository name from git url
git_repo_name()
{
  set -e
  if [ $# -ne 1 ]; then
      echo "Invalid arguments! Usage: $0 git_repo_name  [repo_url]"
      exit 1
  fi
  
  local __repo=${1##*/}
  echo "${__repo%%.*}"
}


# Clone git repository
# usage: 
# cpm git:clone git@github.com:csimeu/cpm.git /path/to/save --branch=v1.0 --composer-update
# cpm git:clone csimeu/cpm /path/to/save --branch=v1.0 --composer-update --domain=github 
# cpm git:clone --repo=csimeu/cpm -d /path/to/save
# cpm git:clone --repo=csimeu/cpm --repo=csimeu/cpm --domain=github 
git_clone()
{
    set -e
    local _params=
    local _branch=
    local _composer=
    # local _is_workspace=0
    # local _team=
    local _path=
    # local _repo=
    # local _workspace_dir=

    parse_git_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi
    
    local repo=$1
    if [[ $repo =~ ^--(.*)$ ]]; then repo=; fi
    if [[ -n "$_repo" ]]; then
        repo=$_repo
    else
        shift 1
    fi
 
    local _pathdest=$1
    if [[ $_pathdest =~ ^--(.*)$ ]]; then _pathdest=; fi
    # if [ -n "$_path" ]; then
    #     _pathdest=$_path
    # fi

    # if [[ -z "$repo" && -n "$_team" ]]; then
    #     repo=${REPOS_LIST[$_team]}
    # fi
    
    if [ -z "$repo" ]; then
        echo "Invalid arguments! Usage: $0 [repo] <pathname> <--branch=v1.0>"
        exit 1
    fi
    
    _branch=${_branch:-'master'}
    # if [ -n "$_branch" ]; then _params+="--branch=$_branch "; fi
    if [ -n "$_env" ]; then _params+="--env=$_env "; fi
    # if [ -n "$_workspace_dir" ]; then _params+="--workspace-dir=$_workspace_dir "; fi
    if [[ $_composer == 1 ]] ; then _params+="--composer-update "; fi
    # if [[ $_is_workspace == 1 ]] ; then _params+="--workspace "; fi
    
    # local _workspace_dir=
    # if [[ -n "$_pathdest" ]]; then
    #     mkdir -p $_pathdest
    # fi

    for repository in $repo
    do
        if ! is_git_url $repository
        then
            repository=$(gitlab_sshUrl $_team $repository)
        fi
        
        # local _pathname=${_pathdest:-"."}/$(git_repo_name $repository)
        echo 
        echo "git clone $repository -b $_branch $_pathdest"
        echo "########################################"
        
        git clone $repository -b $_branch $_pathdest
        local _pathname=${_pathdest}
        if [[ -n "$_pathdest" ]]; then
            _pathname=./$(git_repo_name $repository)
        fi
        
        if [[ $_composer == 1 ]] ; then  
            echo "update composer $_pathname ...";
            composer_update $_pathname $_params ;
        fi
    done
}


# Udapte a git repository branch or tag 
# usage git_update  --branch=v1.0  </path> --composer-update
git_update()
{
  set -e
  local _path=
  local _branch=
  local cmd=
  local _composer=
  local _latest=0
  local _args=$@ 
  # echo $_args
  
  local _parameters=
  parse_arguments $@ 
  set ${_parameters:-"."}

  _path=${_path:-"$1"}
  _path=${_path:-"."}

  # is greater than
  #if [ $# -gt 0 ] then 
  if [ -n "$_path" ] 
  then 
    cd ${_path}
  fi  
  # echo "path $_path"

  
  if [[ $_latest == 1 || _branch == "latest" ]] ; then  
    # echo 'Getting the most recent tag';
    _branch=$(git describe);
  fi

  local current_branch=$(git branch | grep \* | cut -d ' ' -f2);
  if [ -z "$current_branch" ]
  then
      echo failed
      exit 1
  fi

  _branch=${_branch:-"$current_branch"};

  # Check if tag exists
  cmd="git tag | grep -w $_branch"
  if eval $cmd ; 
  then  
    echo 'tag exists';
    git tag -d "$_branch" ;
    cmd="git branch | grep -w $_branch"
    if eval $cmd ;  
    then  
      echo 'branch exist';
      git checkout "master" && git branch -D "$_branch"
    fi
  fi

  git fetch origin && git checkout "$_branch" ;

  cmd="git tag | grep -w $_branch"
  if eval $cmd ; 
  then  
    echo 'tag exists';
    git checkout -b "$_branch" ;
    
  else
    git pull origin $_branch;
  fi

  if [[ $_composer == 1 ]] ; then  
    echo 'update composer';
    composer_update $_args ;
  fi
  # composer_update $webapp_folder
}


# Checks existance of git repository 
git_exists()
{
    # set -e
    if [ $# -eq 0 ]; then
        echo "Invalid arguments! Usage: $0 git_exists [repo_url] "
        exit 1
    fi

    GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git ls-remote $1 -q >/dev/null 2>&1
    
    echo $?
}
