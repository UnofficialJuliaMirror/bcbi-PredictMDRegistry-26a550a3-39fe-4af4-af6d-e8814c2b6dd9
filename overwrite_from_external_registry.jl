import Pkg
import UUIDs

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

original_directory = pwd()
project_root = joinpath(splitpath(@__DIR__)...)
cd(project_root)

include(joinpath(project_root, "ci", "RegistryTestingTools", "types.jl",))

if length(ARGS) < 3
    @error(
        string(
            "syntax: julia overwrite_from_external_registry.jl ",
            "\"EXTERNAL_REGISTRY_NAME\" ",
            "\"EXTERNAL_REGISTRY_UUID\" ",
            "\"EXTERNAL_REGISTRY_URL\" ",
            "[list of packages or interval of packages (optional)]",
            )
        )
    @error(
        string(
            "example usage #1: julia overwrite_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\"",
            )
        )
    @error(
        string(
            "example usage #2: julia overwrite_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"[,)\"",
            )
        )
    @error(
        string(
            "example usage #3: julia overwrite_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"[,M)\"",
            )
        )
    @error(
        string(
            "example usage #4: julia overwrite_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"[Pre,)\"",
            )
        )
    @error(
        string(
            "example usage #5: julia overwrite_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"[G,Req)\"",
            )
        )
    @error(
        string(
            "example usage #6: julia overwrite_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"Foo\"",
            )
        )
    @error(
        string(
            "example usage #7: julia overwrite_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"Foo\" \"Bar\" \"Baz\"",
            )
        )
    error("Not enough command-line arguments")
elseif length(ARGS) == 3
    push!(ARGS, "[,)",)
else
end

external_registry = Pkg.RegistrySpec(
    name = strip(ARGS[1]),
    uuid = UUIDs.UUID(strip(ARGS[2])),
    url = strip(ARGS[3]),
    )

this_registry_configuration = Pkg.TOML.parsefile(
    joinpath(project_root,"Registry.toml",)
    )
this_registry_name_to_path = Dict{String, String}()
this_registry_name_to_uuid = Dict{String, String}()
this_registry_all_packages = String[]
for pair in this_registry_configuration["packages"]
    uuid = pair[1]
    name = pair[2]["name"]
    path = pair[2]["path"]
    push!(this_registry_all_packages, name,)
    this_registry_name_to_path[name] = path
    this_registry_name_to_uuid[name] = uuid
end

unique!(this_registry_all_packages)
sort!(this_registry_all_packages)
n = length(this_registry_all_packages)
@debug(
    "this_registry_all_packages",
    length(this_registry_all_packages),
    this_registry_all_packages,
    repr(this_registry_all_packages),
    )
if _is_interval(ARGS[4])
    this_job_interval = _construct_interval(
        convert(String, strip(ARGS[4]))
        )
    _this_job_interval_contains_x(x) = _interval_contains_x(
        this_job_interval,
        x,
        )
    packages_to_overwrite_in_this_job_interval = this_registry_all_packages[
        _this_job_interval_contains_x.(
            this_registry_all_packages
            )
        ]
else
    packages_to_overwrite_in_this_job_interval = String[
        strip(s) for s in ARGS
        ]
end
unique!(packages_to_overwrite_in_this_job_interval)
sort!(packages_to_overwrite_in_this_job_interval)
@debug(
    "packages_to_overwrite_in_this_job_interval",
    length(packages_to_overwrite_in_this_job_interval),
    packages_to_overwrite_in_this_job_interval,
    repr(packages_to_overwrite_in_this_job_interval),
    )

my_depot = joinpath(maketempdir(), "depot",)
my_environment = joinpath(maketempdir(), "depot",)
rm(my_depot; force = true, recursive = true,)
rm(my_environment;force = true,recursive = true,)
mkpath(my_depot)
mkpath(my_environment)
original_depot_path = [x for x in Base.DEPOT_PATH]
empty!(Base.DEPOT_PATH)
pushfirst!(Base.DEPOT_PATH, my_depot,)
Pkg.activate(my_environment)
Pkg.Registry.add(external_registry)
external_registry_afteradding = first(
    Pkg.Types.collect_registries()
    )
external_registry_configuration = Pkg.TOML.parsefile(
    joinpath(external_registry_afteradding.path,"Registry.toml",)
    )
external_registry_name_to_path = Dict{String, String}()
external_registry_name_to_uuid = Dict{String, String}()
for pair in external_registry_configuration["packages"]
    uuid = pair[1]
    name = pair[2]["name"]
    path = pair[2]["path"]
    external_registry_name_to_path[name] = path
    external_registry_name_to_uuid[name] = uuid
end
external_registry_all_packages = Set(
    collect(keys(external_registry_name_to_path))
    )


n = length(packages_to_overwrite_in_this_job_interval)
for i = 1:n
    name = packages_to_overwrite_in_this_job_interval[i]
    @debug("Overwriting \"$(name)\" (package $(i) of $(n))")
    if name in this_registry_all_packages
        if name in external_registry_all_packages
            our_uuid = this_registry_name_to_uuid[name]
            their_uuid = external_registry_name_to_uuid[name]
            if strip(our_uuid) == strip(their_uuid)
                our_path = this_registry_name_to_path[name]
                their_path = external_registry_name_to_path[name]
                our_full_path = joinpath(project_root, our_path)
                their_full_path = joinpath(
                    external_registry_afteradding.path,
                    their_path,
                    )
                rm(
                    our_full_path;
                    force = true,
                    recursive = true,
                    )
                mkpath(our_full_path)
                our_compat_toml = joinpath(our_full_path, "Compat.toml")
                our_deps_toml = joinpath(our_full_path, "Deps.toml")
                our_package_toml = joinpath(our_full_path, "Package.toml")
                our_versions_toml = joinpath(our_full_path, "Versions.toml")
                their_compat_toml = joinpath(their_full_path, "Compat.toml")
                their_deps_toml = joinpath(their_full_path, "Deps.toml")
                their_package_toml = joinpath(their_full_path, "Package.toml")
                their_versions_toml = joinpath(their_full_path, "Versions.toml")
                if isfile(their_compat_toml)
                    cp(
                        their_compat_toml,
                        our_compat_toml;
                        force = true,
                        )
                end
                if isfile(their_deps_toml)
                    cp(
                        their_deps_toml,
                        our_deps_toml;
                        force = true,
                        )
                end
                if isfile(their_package_toml)
                    cp(
                        their_package_toml,
                        our_package_toml;
                        force = true,
                        )
                end
                if isfile(their_versions_toml)
                    cp(
                        their_versions_toml,
                        our_versions_toml;
                        force = true,
                        )
                end
                @info("Overwrote $(name)")
            else
                error(
                    string(
                        "Our registry says that the UUID of package ",
                        "\"$(name)\" is ",
                        "\"$(our_uuid)\", ",
                        "but the external registry says that ",
                        "the UUID of package ",
                        "\"$(name)\" is ",
                        "\"$(their_uuid)\".",
                        )
                    )
            end
        else
            @warn(
                string(
                    "The external registry does not have the package ",
                    "\"$(name)\" ",
                    "in their registry. ",
                    "Therefore, I will skip the ",
                    "\"$(name)\" package.",
                    )
                )
        end
    else
        error(
            string(
                "We do not have the package ",
                "\"$(name)\" ",
                "in our registry.",
                )
            )
    end
end


empty!(Base.DEPOT_PATH)
for x in original_depot_path
    push!(Base.DEPOT_PATH, x,)
end
unique!(Base.DEPOT_PATH)
cd(original_directory)

# ++++++++++++++++++++++++++++++++++++++++++++++++
