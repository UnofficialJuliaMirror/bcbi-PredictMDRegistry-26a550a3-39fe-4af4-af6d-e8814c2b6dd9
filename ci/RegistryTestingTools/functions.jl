##### Beginning of file

import LibGit2
import Pkg

function pairwise_equality(x, y)::Matrix{Bool}
    length_x::Int = length(x)
    length_y::Int = length(y)
    result_matrix::Matrix{Bool} = Matrix{Bool}(undef, length_x, length_y)
    for i = 1:length(x)
        for j = 1:length(y)
            result_matrix[i,j] = x[i] == y[j]
        end
    end
    return result_matrix
end

any_pairwise_equality(x, y)::Bool = any(pairwise_equality(x, y))

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
    original_directory::String = pwd()
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
    unique!(all_packages)
    sort!(all_packages)
    n = length(all_packages)
    @debug("all_packages ($(n)):")
    for i = 1:n
        @debug("$(i). $(all_packages[i])")
    end
    clone_ignore::Vector{String} = configuration["clone"]["ignore"]
    unique!(clone_ignore)
    sort!(clone_ignore)
    n = length(clone_ignore)
    @debug("clone_ignore ($(n)):")
    for i = 1:n
        @debug("$(i). $(clone_ignore[i])")
    end
    packages_to_clone::Vector{String} = strip.(
        setdiff(all_packages, clone_ignore,)
        )
    unique!(packages_to_clone)
    sort!(packages_to_clone)
    n = length(packages_to_clone)
    @debug("packages_to_clone ($(n)):")
    for i = 1:n
        @debug("$(i). $(packages_to_clone[i])")
    end
    _this_job_interval_contains_x(x) = _interval_contains_x(
        this_job_interval,
        x,
        )
    packages_to_clone_in_this_job_interval = packages_to_clone[
        _this_job_interval_contains_x.(
            packages_to_clone
            )
        ]
    unique!(packages_to_clone_in_this_job_interval)
    sort!(packages_to_clone_in_this_job_interval)
    n = length(packages_to_clone_in_this_job_interval)
    @debug("packages_to_clone_in_this_job_interval ($(n)):")
    for i = 1:n
        @debug("$(i). $(packages_to_clone_in_this_job_interval[i])")
    end
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
    registry_configuration = Pkg.TOML.parsefile(
        joinpath(registry_path,"Registry.toml",)
        )
    name_to_path = Dict{String, String}()
    for pair in registry_configuration["packages"]
        name = pair[2]["name"]
        path = pair[2]["path"]
        name_to_path[name] = path
    end
    n = length(packages_to_clone_in_this_job_interval)
    for i = 1:n
        name = packages_to_clone_in_this_job_interval[i]
        @debug(
            string(
                "Checking git-tree-sha1 values for \"$(name)\" ",
                "(package $(i) of $(n))",
                )
            )
        path = name_to_path[name]
        previous_directory = pwd()
        package_configuration = Pkg.TOML.parsefile(
            joinpath(path,"Package.toml")
            )
        versions_configuration = Pkg.TOML.parsefile(
            joinpath(path,"Versions.toml")
            )
        git_tree_sha1_list = String[]
        for version in keys(versions_configuration)
            push!(
                git_tree_sha1_list,
                versions_configuration[version]["git-tree-sha1"],
                )
        end
        repo_url = package_configuration["repo"]
        tmp_repo_clone_path = mktempdir()
        Base.shred!(LibGit2.CachedCredentials()) do creds
            LibGit2.with(
                Pkg.GitTools.clone(
                    repo_url,
                    tmp_repo_clone_path;
                    header = "git-repo from $(repr(repo_url))",
                    credentials = creds,
                    )
                ) do repo
            end
        end
        cd(tmp_repo_clone_path)
        for git_tree_sha1_value in git_tree_sha1_list
            cat_file_type = lowercase(
                strip(
                    read(
                        `git cat-file -t $(git_tree_sha1_value)`,
                        String,
                        )
                    )
                )
            if cat_file_type != "tree"
                @debug(
                    "git_tree_sha1 does not correspond to a tree",
                    name,
                    path,
                    repo_url,
                    git_tree_sha1_value,
                    cat_file_type,
                    )
                error("git_tree_sha1 does not correspond to a tree")
            end
        end
        cd(previous_directory)
        rm(
            tmp_repo_clone_path;
            force = true,
            recursive = true,
            )
    end
    cd(original_directory)
    return nothing
end

##### End of file
