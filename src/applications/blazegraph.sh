#!/bin/bash

# Install blazegraph


function blazegraph_install() 
{
    set -e
    local appName=blazegraph
    local FORCE=0
    local IS_DEFAULT=0
    local version=$BLAZEGRAPH_DEFAULT_VERSION
    local data=/var/lib
    local name=
    local catalina_home=$CATALINA_HOME
    local data_dir=
    local config_dir=
    # local file_config=
    # echo $@

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    name=${name:-"$appName-$version"}
    name=${name//./-/}

    if [ '1' == $IS_DEFAULT ]; then 
        # catalina_home=/usr/share/tomcat; 
        name=$appName
    fi

    if [ -z $catalina_home ]; then
        echo "If not --default, --catalina_home value is required"
        exit 1
    fi

    if [ '1' == $FORCE ]; then 
        sudo rm -f ${catalina_home}/webapps/${name}.war
    fi

    if [ -f ${catalina_home}/webapps/${name}.war ]
    then 
        echo "Current file already exist: ${catalina_home}/webapps/${name}.war"
        exit 0
    fi

    case "$version" in

        "2") version=2.1.5;;

        *)
        ;;
    esac

    if [ ! -f /tmp/releases/blazegraph-$version.war ];
    then
        echo "https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${version//\./_}/blazegraph.war -o /tmp/releases/blazegraph-$version.war"
        curl -fSL https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${version//\./_}/blazegraph.war -o /tmp/releases/blazegraph-$version.war
    fi

    sudo cp -f /tmp/releases/blazegraph-$version.war ${catalina_home}/webapps/${name}.war

    if [ -z $data_dir ]; then
        data_dir="${data}/${name}"
    fi

    if [ -z $config_dir ]; then
        config_dir="/etc/${name}"
    fi

    sudo mkdir -p $data_dir $config_dir
    # sudo chown tomcat:tomcat $data_dir/ $config_dir
    if [ -d /etc/tomcat ]; then
        echo 'JAVA_OPTS="-Dcom.bigdata.rdf.sail.webapp.ConfigParams.propertyFile='$config_dir'/RWStore.properties"'| sudo tee -a /etc/tomcat/$name.conf
    fi
    
    echo 'export JAVA_OPTS="\$JAVA_OPTS -Dcom.bigdata.rdf.sail.webapp.ConfigParams.propertyFile='$config_dir'/RWStore.properties"' | sudo tee /etc/profile.d/blazegraph.sh
    source /etc/profile.d/blazegraph.sh

    if [ ! -f $config_dir/blazegraph.properties ]; then 
        sudo cat > $config_dir/blazegraph.properties << EOF
com.bigdata.rdf.sail.isolatableIndices=false
com.bigdata.rdf.store.AbstractTripleStore.justify=true
com.bigdata.rdf.sail.truthMaintenance=true
com.bigdata.rdf.sail.namespace=islandora
com.bigdata.rdf.store.AbstractTripleStore.quads=false
com.bigdata.namespace.islandora.lex.com.bigdata.btree.BTree.branchingFactor=400
com.bigdata.journal.Journal.groupCommit=false
com.bigdata.namespace.islandora.spo.com.bigdata.btree.BTree.branchingFactor=1024
com.bigdata.rdf.store.AbstractTripleStore.geoSpatial=false
com.bigdata.rdf.store.AbstractTripleStore.statementIdentifiers=false
EOF
    fi

    if [ ! -f $config_dir/RWStore.properties ]; then 
        sudo cat > $config_dir/RWStore.properties << EOF
com.bigdata.journal.AbstractJournal.file=$data_dir/bigdata.jnl
com.bigdata.journal.AbstractJournal.bufferMode=DiskRW
com.bigdata.service.AbstractTransactionService.minReleaseAge=1
com.bigdata.journal.Journal.groupCommit=false
com.bigdata.btree.writeRetentionQueue.capacity=4000
com.bigdata.btree.BTree.branchingFactor=128
com.bigdata.journal.AbstractJournal.initialExtent=209715200
com.bigdata.journal.AbstractJournal.maximumExtent=209715200
com.bigdata.rdf.sail.truthMaintenance=false
com.bigdata.rdf.store.AbstractTripleStore.quads=true
com.bigdata.rdf.store.AbstractTripleStore.statementIdentifiers=false
com.bigdata.rdf.store.AbstractTripleStore.textIndex=false
com.bigdata.rdf.store.AbstractTripleStore.axiomsClass=com.bigdata.rdf.axioms.NoAxioms
com.bigdata.namespace.kb.lex.com.bigdata.btree.BTree.branchingFactor=400
com.bigdata.namespace.kb.spo.com.bigdata.btree.BTree.branchingFactor=1024
com.bigdata.journal.Journal.collectPlatformStatistics=false
EOF
    fi
    
    # https://nvbach.blogspot.com/2019/04/installing-blazegraph-on-linux-debian.html


    # mkdir -p $config_dir/
    # chown tomcat:tomcat -R $config_dir/
    echo ">> Installed application '$appName' (version = $version) in ${catalina_home}/webapps/${name}.war"
}

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
#   blazegraph_install $@
# fi

