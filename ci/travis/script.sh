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

julia $JULIA_FLAGS $TRAVIS_BUILD_DIR/ci/travis/test_registry.jl
julia $JULIA_FLAGS $TRAVIS_BUILD_DIR/ci/travis/compare_juliaregistries_general.jl
julia $JULIA_FLAGS $TRAVIS_BUILD_DIR/compress.jl "$JOB"
julia $JULIA_FLAGS $TRAVIS_BUILD_DIR/overwrite_from_external_registry.jl "General" "23338594-aafe-5451-b93e-139f81909106" "https://github.com/JuliaRegistries/General.git" "$JOB"

##### End of file
