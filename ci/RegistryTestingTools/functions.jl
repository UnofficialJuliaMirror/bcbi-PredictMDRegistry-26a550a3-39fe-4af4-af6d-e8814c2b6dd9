##### Beginning of file

import Pkg

function test_registry(
        registry_path::AbstractString;
        additional_registries::Vector{Pkg.RegistrySpec} = Pkg.RegistrySpec[
            Pkg.RegistrySpec(name="General"),
            ],
        job::AbstractString = ENV["JOB"],
        config_file::AbstractString = joinpath(
            registry_path,
            "ci",
            "ci.toml",
            ),
        )::Nothing
    this_job_interval::AbstractInterval = _construct_interval(
        convert(String, strip(job))
        )
    configuration::Dict{String,Any} = Pkg.TOML.parsefile(config_file)
    all_packages::Vector{String} = String[]
    for (root, dirs, files) in walkdir(registry_path)
        for file in files
            if endswith(lowercase(strip(file)), ".toml")
                file_contents = Pkg.TOML.parsefile(
                    joinpath(root, file,)
                    )
                if lowercase(strip(file)) == "registry.toml"
                    append!(
                        all_packages,
                        [x["name"] for x in
                            collect(values(file_contents["packages"]))],
                        )
                end
                if lowercase(strip(file)) == "package.toml"
                    push!(
                        all_packages,
                        file_contents["name"],
                        )
                end
            end
        end
    end
    clone_ignore::Vector{String} = configuration["clone"]["ignore"]
    packages_to_clone::Vector{String} = strip.(
        setdiff(all_packages, clone_ignore,)
        )
    unique!(packages_to_clone)
    sort!(packages_to_clone)
    _this_job_interval_contains_x(x) = _interval_contains_x(
        this_job_interval,
        x,
        )
    packages_to_clone_in_this_job_interval = packages_to_clone[
        _this_job_interval_contains_x.(
            packages_to_clone
            )
        ]
    my_depot::String = joinpath(mktempdir(), "depot",)
    my_environment::String = joinpath(mktempdir(), "depot",)
    rm(my_depot; force = true, recursive = true,)
    rm(my_environment;force = true,recursive = true,)
    mkpath(my_depot)
    mkpath(my_environment)
    original_depot_path = [x for x in Base.DEPOT_PATH]
    empty!(Base.DEPOT_PATH)
    pushfirst!(Base.DEPOT_PATH, my_depot,)
    Pkg.activate(my_environment)
    Pkg.Registry.add(Pkg.RegistrySpec(path=registry_path,))
    for additional_registry in additional_registries
        Pkg.Registry.add(additional_registry)
        Pkg.Registry.update(additional_registry)
    end
    n = length(packages_to_clone_in_this_job_interval)
    for i = 1:n
        name = packages_to_clone_in_this_job_interval[i]
        @debug("Adding \"$(name)\" (package $(i) of $(n))")
        rm(my_environment;force = true,recursive = true,)
        mkpath(my_environment)
        Pkg.add(name)
        Pkg.build(name)
    end
    rm(my_depot; force = true, recursive = true,)
    rm(my_environment;force = true,recursive = true,)
    empty!(Base.DEPOT_PATH)
    for x in original_depot_path
        push!(Base.DEPOT_PATH, x,)
    end
    unique!(Base.DEPOT_PATH)
    return nothing
end

##### End of file
