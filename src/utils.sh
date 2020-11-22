
#!/bin/bash

# Checks if given string is an valid url
function is_url()
{
    # -- supported protocols (HTTP, HTTPS, FTP, FTPS, SCP, SFTP, TFTP, DICT, TELNET, LDAP or FILE) --
    regex='([a-z]{3,6})://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    string=$1
    if [[ $string =~ $regex ]]
    then 
        true
    else
        false
    fi
}

# Transform snake words to camel
function snake_to_camel()
{
    echo $(echo $1 | sed -r 's/(^|_)(\w)/\U\2/g' )
}

# Transform camel words to snake
function camel_to_snake() 
{
    echo $(echo $1 | sed 's/\(.\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]')
}

