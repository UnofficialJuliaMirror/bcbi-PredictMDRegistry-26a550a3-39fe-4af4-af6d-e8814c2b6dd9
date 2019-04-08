#!/bin/bash

##### Beginning of file

set -ev

export TRAVIS_JULIA_VERSION=$JULIA_VER
echo "TRAVIS_JULIA_VERSION=$TRAVIS_JULIA_VERSION"

export JULIA_FLAGS="--check-bounds=yes --code-coverage=all --color=yes --compiled-modules=yes --inline=no"
echo "JULIA_FLAGS=$JULIA_FLAGS"

export PATH="${PATH}:${TRAVIS_HOME}/julia/bin"

julia $JULIA_FLAGS -e "VERSION >= v\"0.7.0-DEV.3630\" && using InteractiveUtils; versioninfo()"

rm -rf $HOME/.julia
rm -rf $TRAVIS_HOME/.julia

julia $JULIA_FLAGS -e '
    TRAVIS_BUILD_DIR = ENV["TRAVIS_BUILD_DIR"];
    pushfirst!(
        Base.LOAD_PATH,
        joinpath(TRAVIS_BUILD_DIR, "ci", "RegistryTestingTools",),
        );
    import RegistryTestingTools;
    RegistryTestingTools.test_registry(TRAVIS_BUILD_DIR);
    '

julia $JULIA_FLAGS $TRAVIS_BUILD_DIR/compress.jl "$JOB"

##### End of file
