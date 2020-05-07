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
    ls /opt/conda/bin
    conda config --set anaconda_upload no
    apt-get update
    apt-get install -y build-essential
    mkdir /opt/output
    source  /opt/conda/bin/activate
    conda create -n myenv python=3.6 -c conda-forge
    conda config --add channels conda-forge
    conda install --yes -c conda-forge pip
    conda install --yes -c conda-forge numpy cython
    conda install --yes -c conda-forge nose mdtraj
    conda install --yes conda-verify
    conda activate myenv
    anaconda login --username $INPUT_ANACONDAUSERNAME --password $INPUT_ANACONDAPASSWORD
    conda build . --output-folder /opt/output
    anaconda upload --user bowman-lab $(ls /opt/output/noarch/*.tar.gz)
    anaconda logout
}

go_to_build_dir
check_if_setup_file_exists
check_if_meta_yaml_file_exists
upload_package
