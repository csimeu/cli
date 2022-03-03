#!/bin/bash
# sed -i -e 's/\r$//' scriptname.sh


# copy local env
function localenv() 
{
    set -e
    local filename='.env.local'
    local file
    read_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    if [ -f $filename ]; then cp -f $filename $filename.bak-$(date +%Y-%m-%d); fi
    > $filename

    if [[ -n $file ]]; then
        # take copy of file and replace vars found value 
        if [[ ! -f $file && ! -f $file ]]; then
            echo "No such file: $file"
            exit 1
        fi
        cp -f $file $filename
        for env in `env`; do
            varName=${env%=*}
            varValue=${env##*=}

            if is_alphanum $varName; then
                echo "${varName}=\"$varValue\""
                sed -i -e "s|^$varName=*$|${varName}=\"${varValue/\|//~/}\"|g" $filename
            fi
        done
        echo  ">> Cloned file '$file' in '$filename' with locals environments variables"
        exit 0
    fi

    # echo 'go'
	for env in `env`; do
		varName=${env%=*}
		varValue=${env##*=}
        if [[ " $@ " == *" $varName "* ]]; then
            echo "${varName}=\"$varValue\"" >> $filename
        fi
	done
    
    echo ">> create/updated file '$filename' with locals environments variables"
}

