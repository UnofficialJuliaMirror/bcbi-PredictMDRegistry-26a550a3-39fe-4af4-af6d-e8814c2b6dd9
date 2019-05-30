import Pkg

TRAVIS_BUILD_DIR = ENV["TRAVIS_BUILD_DIR"]

pushfirst!(Base.LOAD_PATH,joinpath(TRAVIS_BUILD_DIR, "ci", "RegistryTestingTools",),);

import RegistryTestingTools

# RegistryTestingTools.test_registry(TRAVIS_BUILD_DIR)

RegistryTestingTools.compare_external_registry(
    TRAVIS_BUILD_DIR,
    Pkg.RegistrySpec(
        name = "General",
        uuid = "23338594-aafe-5451-b93e-139f81909106",
        url = "https://github.com/JuliaRegistries/General.git",
        ),
    )
