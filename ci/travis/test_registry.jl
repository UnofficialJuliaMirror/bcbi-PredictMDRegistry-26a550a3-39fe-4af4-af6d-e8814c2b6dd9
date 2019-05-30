import Pkg

TRAVIS_BUILD_DIR = ENV["TRAVIS_BUILD_DIR"]

pushfirst!(Base.LOAD_PATH,joinpath(TRAVIS_BUILD_DIR, "ci", "RegistryTestingTools",),);

import RegistryTestingTools

RegistryTestingTools.test_registry(TRAVIS_BUILD_DIR)
