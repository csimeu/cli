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
    local catalina_home=
    local fcrepo_config=
    local file_config=
    # echo $@

    local _parameters=
    read_application_arguments $@ 
    if [ -n "$_parameters" ]; then set $_parameters; fi

    name=${name:-"$appName-$version"}
    name=${name//./-/}

    if [ '1' == $IS_DEFAULT ]; then 
        catalina_home=/usr/share/tomcat; 
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

    sudo mkdir -p /var/lib/blazegraph/ /etc/blazegraph
    sudo chown tomcat:tomcat /var/lib/blazegraph/ /etc/blazegraph
    echo 'JAVA_OPTS="-Dcom.bigdata.rdf.sail.webapp.ConfigParams.propertyFile=/etc/blazegraph/RWStore.properties"'| sudo tee -a /etc/tomcat/tomcat.conf
    
    if [ ! -f /etc/blazegraph/blazegraph.properties ]; then 
        sudo cat > /etc/blazegraph/blazegraph.properties << EOF
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

    if [ ! -f /etc/blazegraph/RWStore.properties ]; then 
        sudo cat > /etc/blazegraph/RWStore.properties << EOF
com.bigdata.journal.AbstractJournal.file=/var/lib/blazegraph/bigdata.jnl
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


    # mkdir -p /etc/blazegraph/
    # chown tomcat:tomcat -R /etc/blazegraph/
    echo ">> Installed application '$appName' (version = $version) in ${catalina_home}/webapps/${name}.war"
}

## detect if a script is being sourced or not
# if [[ $_ == $0 ]] 
# then
#   blazegraph_install $@
# fi

