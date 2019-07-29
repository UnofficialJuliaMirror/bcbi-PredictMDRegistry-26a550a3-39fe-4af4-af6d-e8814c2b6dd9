##### Beginning of file

import LibGit2
import Pkg

function maketempdir()::String
    path::String = mktempdir()
    atexit(() -> _force_remove_path(path))
    return path
end

function _force_remove_path(path)::Nothing
    try
        rm(path; force = true, recursive = true)
    catch
    end
    return nothing
end

function pairwise_equality(
        x::AbstractVector,
        y::AbstractVector,
        )::Matrix{Bool}
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

function version_string_equality(x::AbstractString,y::AbstractString,)::Bool
    x_converted::String = convert(String, x)
    y_converted::String = convert(String, y)
    result = version_string_equality(x_converted, y_converted,)
    return result
end

function version_string_equality(x::String, y::String,)::Bool
    x_stripped::String = strip(x)
    x_stripped_lowercase::String = lowercase(x_stripped)
    all_x = [
        x_stripped,
        x_stripped_lowercase,
        VersionNumber(x_stripped),
        VersionNumber(x_stripped_lowercase),
        strip(string(VersionNumber(x_stripped))),
        strip(string(VersionNumber(x_stripped_lowercase))),
        VersionNumber(strip(string(VersionNumber(x_stripped)))),
        VersionNumber(strip(string(VersionNumber(x_stripped_lowercase)))),
        ]
    y_stripped::String = strip(y)
    y_stripped_lowercase::String = lowercase(y_stripped)
    all_y = [
        y_stripped,
        y_stripped_lowercase,
        VersionNumber(y_stripped),
        VersionNumber(y_stripped_lowercase),
        strip(string(VersionNumber(y_stripped))),
        strip(string(VersionNumber(y_stripped_lowercase))),
        VersionNumber(strip(string(VersionNumber(y_stripped)))),
        VersionNumber(strip(string(VersionNumber(y_stripped_lowercase)))),
        ]
    result::Bool = any_pairwise_equality(
        all_x,
        all_y,
        )
    return result
end

function is_valid_version_string(x::AbstractString)::Bool
    x_converted::String = convert(String, x,)
    result = is_valid_version_string(x_converted)
    return result
end

function is_valid_version_string(x::String)::Bool
    x_stripped::String = strip(x)
    result_stripped::Bool = try
        isa(VersionNumber(x_stripped), VersionNumber)
    catch
        false
    end
    x_stripped_lowercase::String = lowercase(x_stripped)
    result_stripped_lowercase::Bool = try
        isa(VersionNumber(x_stripped_lowercase), VersionNumber)
    catch
        false
    end
    result::Bool = result_stripped && result_stripped_lowercase
    return result
end

function compare_external_registry(
        registry_path::AbstractString,
        external_registry::Pkg.RegistrySpec;
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
    registry_configuration_myregistry = Pkg.TOML.parsefile(
        joinpath(registry_path,"Registry.toml",)
        )
    name_to_path_myregistry = Dict{String, String}()
    for pair in registry_configuration_myregistry["packages"]
        name = pair[2]["name"]
        path = pair[2]["path"]
        name_to_path_myregistry[name] = path
    end
    all_packages::Vector{String} = collect(keys(name_to_path_myregistry))
    sort!(all_packages)
    unique!(all_packages)
    n = length(all_packages)
    @debug("all_packages ($(n)):")
    for i = 1:n
        @debug("$(i). $(all_packages[i])")
    end
    _this_job_interval_contains_x(x) = _interval_contains_x(
        this_job_interval,x,
        )
    packages_in_this_job_interval = all_packages[
        _this_job_interval_contains_x.(all_packages)
        ]
    unique!(packages_in_this_job_interval)
    sort!(packages_in_this_job_interval)
    n = length(packages_in_this_job_interval)
    @debug("packages_in_this_job_interval ($(n)):")
    for i = 1:n
        @debug("$(i). $(packages_in_this_job_interval[i])")
    end
    my_depot::String = joinpath(maketempdir(), "depot",)
    my_environment::String = joinpath(maketempdir(), "depot",)
    rm(my_depot; force = true, recursive = true,)
    rm(my_environment;force = true,recursive = true,)
    mkpath(my_depot)
    mkpath(my_environment)
    original_depot_path = [x for x in Base.DEPOT_PATH]
    empty!(Base.DEPOT_PATH)
    pushfirst!(Base.DEPOT_PATH, my_depot,)
    Pkg.activate(my_environment)
    Pkg.Registry.add(external_registry)
    external_registry_afteradding::Pkg.Types.RegistrySpec = first(
        Pkg.Types.collect_registries()
        )
    registry_configuration_externalregistry = Pkg.TOML.parsefile(
        joinpath(external_registry_afteradding.path,"Registry.toml",)
        )
    name_to_path_externalregistry = Dict{String, String}()
    for pair in registry_configuration_externalregistry["packages"]
        name = pair[2]["name"]
        path = pair[2]["path"]
        name_to_path_externalregistry[name] = path
    end
    packages_in_external_registry = Set(
        collect(keys(name_to_path_externalregistry))
        )
    n = length(packages_in_this_job_interval)
    for i = 1:n
        ### @debug(string("Checking git-tree-sha1 values for \"$(name)\" ","",))
        name = packages_in_this_job_interval[i]
        @debug(
            string(
                "Comparing git-tree-sha1 values for \"$(name)\" ",
                "(package $(i) of $(n))",
                )
            )
        my_path = name_to_path_myregistry[name]
        if name in packages_in_external_registry
            their_path = name_to_path_externalregistry[name]
            my_versions_toml = Pkg.TOML.parsefile(
                joinpath(
                    registry_path,
                    my_path,
                    "Versions.toml",
                    )
                )
            their_versions_toml = Pkg.TOML.parsefile(
                joinpath(
                    external_registry_afteradding.path,
                    their_path,
                    "Versions.toml",
                    )
                )
            my_version_strings = collect(keys(my_versions_toml))
            their_version_strings = collect(keys(their_versions_toml))
            for j = 1:length(my_version_strings)
                my_version = my_version_strings[j]
                my_git_tree_sha1 = strip(
                    my_versions_toml[
                        my_version]["git-tree-sha1"]
                    )
                for k = 1:length(their_version_strings)
                    their_version = their_version_strings[k]
                    if version_string_equality(my_version, their_version)
                        their_git_tree_sha1 = strip(
                            their_versions_toml[
                                their_version]["git-tree-sha1"]
                            )
                        if my_git_tree_sha1 == their_git_tree_sha1
                            @debug(
                                "good news: git-tree-sha1 values match",
                                my_version,
                                their_version,
                                my_git_tree_sha1,
                                their_git_tree_sha1,
                                )
                        else
                            @error(
                                "git-tree-sha1 mismatch",
                                my_version,
                                their_version,
                                my_git_tree_sha1,
                                their_git_tree_sha1,
                                )
                            error("git-tree-sha1 mismatch")
                        end

                    end
                end
            end
        end
    end
    rm(my_depot; force = true, recursive = true,)
    rm(my_environment;force = true,recursive = true,)
    empty!(Base.DEPOT_PATH)
    for x in original_depot_path
        push!(Base.DEPOT_PATH, x,)
    end
    unique!(Base.DEPOT_PATH)
    cd(original_directory)
    return nothing
end

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
                    if !haskey(file_contents, "packages")
                        file_contents["packages"] = Dict{String, Any}()
                    end
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
                if lowercase(strip(file)) == "versions.toml"
                    for version_number in keys(file_contents)
                        if !is_valid_version_string(version_number)
                            @error(
                                "Not a valid version number",
                                version_number,
                                root,
                                file,
                                )
                            error("Not a valid version number")
                        end
                    end
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
    my_depot::String = joinpath(maketempdir(), "depot",)
    my_environment::String = joinpath(maketempdir(), "depot",)
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
        tmp_repo_clone_path = maketempdir()
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
