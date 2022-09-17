#!/bin/bash

# parse_git_branch() {
#     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
# }

# If id command returns zero, you got root access.
if [ $(id -u) -eq 0 ];
then # you are root, set red color prompt
  export PS1='\[\033[0;31m\]\u@\H:\[\033[33m\]\w \[\033[36m\]$(git_branch)\[\033[31m\]\n\[\033[0m\]└─ $ '
else # normal
  export PS1='\[\033[1;34m\]\u@\H:\[\033[1;33m\]\w \[\033[1;32m\]$(git_branch)\n\[\033[0m\]└─ $ '
fi

# export PS1='%F{cyan}%n@%m%f %F{green}%~%f %F{yellow}$%f '
# export PS1="%F{cyan}%n@%m%f %F{green}%~%f%F{blue}[$(git_branch)]%f \n%F{yellow}└─ $%f "
# export PS1=$'\e[1;34m%n@%m:\e[1;33m %~ \e[1;32m$(git_branch)\n\e[0m└─ $'
