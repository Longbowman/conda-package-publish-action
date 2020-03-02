#!/bin/bash

set -ex
set -o pipefail

go_to_build_dir() {
    if [ ! -z $INPUT_SUBDIR ]; then
        cd $INPUT_SUBDIR
    fi
}

check_if_setup_file_exists() {
    if [ ! -f setup.py ]; then
        echo "setup.py must exist in the directory that is being packaged and published."
        exit 1
    fi
}

check_if_meta_yaml_file_exists() {
    if [ ! -f meta.yaml ]; then
        echo "meta.yaml must exist in the directory that is being packaged and published."
        exit 1
    fi
}

upload_package(){
    conda config --set anaconda_upload yes
    apt-get update
    apt-get install -y build-essential
    conda create -n myenv python=3.6
    activate myenv
    echo $PWD
    echo "$VIRTUAL_ENV"
    conda install --yes pip
    conda install --yes numpy cython
    conda install --yes -c conda-forge nose mdtraj  
    anaconda login --username $INPUT_ANACONDAUSERNAME --password $INPUT_ANACONDAPASSWORD
    echo $PWD
    echo "$VIRTUAL_ENV"
    conda build /github/workspace 
    anaconda logout
}

go_to_build_dir
check_if_setup_file_exists
check_if_meta_yaml_file_exists
upload_package
