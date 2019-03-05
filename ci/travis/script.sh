#!/bin/bash

##### Beginning of file

set -ev

export TRAVIS_JULIA_VERSION=$JULIA_VER
echo "TRAVIS_JULIA_VERSION=$TRAVIS_JULIA_VERSION"

export JULIA_FLAGS="--check-bounds=yes --code-coverage=all --color=yes --compiled-modules=yes --inline=no"
echo "JULIA_FLAGS=$JULIA_FLAGS"

export PATH="${PATH}:${TRAVIS_HOME}/julia/bin"

julia $JULIA_FLAGS -e "VERSION >= v\"0.7.0-DEV.3630\" && using InteractiveUtils; versioninfo()"

julia $JULIA_FLAGS -e '
    ENV["JULIA_DEBUG"] = "all";
    TRAVIS_BUILD_DIR = strip(ENV["TRAVIS_BUILD_DIR"]);
    @info("TRAVIS_BUILD_DIR: ", TRAVIS_BUILD_DIR,)
    import Pkg;
    Pkg.Registry.add(Pkg.RegistrySpec(path=TRAVIS_BUILD_DIR,));
    Pkg.Registry.add(Pkg.RegistrySpec(name="General",));
    Pkg.Registry.update(Pkg.RegistrySpec(name="General",));
    '

julia $JULIA_FLAGS -e '
    ENV["JULIA_DEBUG"] = "all";
    import Pkg;
    Pkg.add("PredictMD");
    Pkg.build("PredictMD");
    '

julia $JULIA_FLAGS -e '
    ENV["JULIA_DEBUG"] = "all";
    import Pkg;
    Pkg.add("PredictMDExtra");
    Pkg.build("PredictMDExtra");
    '

julia $JULIA_FLAGS -e '
    ENV["JULIA_DEBUG"] = "all";
    import Pkg;
    Pkg.add("PredictMDFull");
    Pkg.build("PredictMDFull");
    '

julia $JULIA_FLAGS -e '
    ENV["JULIA_DEBUG"] = "all";
    import Pkg;
    Pkg.build("PredictMD");
    Pkg.build("PredictMDExtra");
    Pkg.build("PredictMDFull");
    '

##### End of file
