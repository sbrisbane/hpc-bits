#!/bin/bash

echo "warning, killing this will ruin your bashrc - see backup in  ~/.bashrc.bk"

#change this so only the module file is set up
#NOINSTALL=echo
NOINSTALL=""

NOW=$( date +%Y%m%d)
ROOT=/apps/software/el9/miniconda3
VER=$NOW
mkdir -p  $ROOT/build  $ROOT/$VER

$NOINSTALL wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /apps/software/el9/miniconda3/build/miniconda-installer.sh
$NOINSTALL bash $ROOT/build/miniconda-installer.sh -b -u -p $ROOT/$VER


$NOINSTALL /bin/mv ~/.bashrc ~/.bashrc.bk

$NOINSTALL $ROOT/$VER/bin/conda init bash
$NOINSTALL /bin/mv ~/.bashrc  $ROOT/$VER/miniconda-environment.sh
$NOINSTALL /bin/mv ~/.bashrc.bk ~/.bashrc


MODULEDIR=/apps/modules/el9/
mkdir -p $MODULEDIR/miniconda3
MODULEFILE=$MODULEDIR/miniconda3/$VER
mkdir -p $MODULEDIR/miniconda3

cat << EOF > $MODULEFILE
#%Module1.0
##
## miniconda3@$NOW
##
proc ModulesHelp { } {
    global version
    puts stderr "This module sets up the environment for Conda."
}


module-whatis { Miniconda is a free and open-source distribution of the Python and R programming languages for scientific computing, that aims to simplify package management and deployment. Package versions are managed by the package management system conda. }

proc ModulesHelp { } {
    puts stderr {Name   : miniconda3}
    puts stderr {Version: $VER}
    puts stderr {}
    puts stderr { Anaconda is a free and open-source distribution of the Python and R}
    puts stderr {programming languages for scientific computing, that aims to simplify}
    puts stderr {package management and deployment. Package versions are managed by the}
    puts stderr {package management system conda.}
}

set ROOT $ROOT
prepend-path PATH {$ROOT/$VER/bin}
prepend-path MANPATH {$ROOT/$VER/man}
prepend-path MANPATH {$ROOT/$VER/share/man}
prepend-path ACLOCAL_PATH {$ROOT/$VER/share/aclocal}
prepend-path PKG_CONFIG_PATH {$ROOT/$VER/lib/pkgconfig}
prepend-path PKG_CONFIG_PATH {$ROOT/$VER/share/pkgconfig}
prepend-path CMAKE_PREFIX_PATH {$ROOT/$VER/.}
setenv CONDA_EXE {$ROOT/$VER/bin/conda}
setenv CONDA_PYTHON_EXE {$ROOT/$VER/bin/python}
setenv CONDA_SHLVL {0}
setenv _CE_CONDA {}
setenv _CE_M {}
prepend-path PATH {$ROOT/$VER/condabin}
append-path MANPATH {}



# Path to the Conda installation
puts stdout "source $ROOT/$VER/miniconda-environment.sh";

EOF
