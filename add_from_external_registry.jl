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

if length(ARGS) < 3
    @error(
        string(
            "syntax: julia add_from_external_registry.jl ",
            "\"EXTERNAL_REGISTRY_NAME\" ",
            "\"EXTERNAL_REGISTRY_UUID\" ",
            "\"EXTERNAL_REGISTRY_URL\" ",
            "[list of packages]",
            )
        )
    @error(
        string(
            "example usage #1: julia add_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"Foo\"",
            )
        )
    @error(
        string(
            "example usage #2: julia add_from_external_registry.jl ",
            "\"General\" ",
            "\"23338594-aafe-5451-b93e-139f81909106\" ",
            "\"https://github.com/JuliaRegistries/General.git\" ",
            "\"Foo\" \"Bar\" \"Baz\"",
            )
        )
    error("Not enough command-line arguments")
end

external_registry = Pkg.RegistrySpec(
    name = strip(ARGS[1]),
    uuid = UUIDs.UUID(strip(ARGS[2])),
    url = strip(ARGS[3]),
    )

this_registry_toml_path= joinpath(project_root, "Registry.toml")
this_registry_configuration = Pkg.TOML.parsefile(this_registry_toml_path)
this_registry_name_to_path = Dict{String, String}()
this_registry_name_to_uuid = Dict{String, String}()
this_registry_all_packages = String[]
if !haskey(this_registry_configuration, "packages")
    this_registry_configuration["packages"] = Dict{String, Any}()
end
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
packages_to_add_from_external_registry = String[
    strip(s) for s in ARGS[4:end]
    ]
unique!(packages_to_add_from_external_registry)
sort!(packages_to_add_from_external_registry)
@debug(
    "packages_to_add_from_external_registry",
    length(packages_to_add_from_external_registry),
    packages_to_add_from_external_registry,
    repr(packages_to_add_from_external_registry),
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

info_messages = Vector{String}(undef, 0)
n = length(packages_to_add_from_external_registry)
for i = 1:n
    name = packages_to_add_from_external_registry[i]
    @debug("Adding \"$(name)\" (package $(i) of $(n))")
    if name in external_registry_all_packages
        if name in this_registry_all_packages
            error(
                string(
                    "We already have the package \"$(name)\" ",
                    "in our registry. ",
                    "Please delete the \"$(name)\" package ",
                    "and then try again.",
                    )
                )
        else
            their_uuid = external_registry_name_to_uuid[name]
            their_path = external_registry_name_to_path[name]
            their_full_path = joinpath(
                external_registry_afteradding.path,
                their_path,
                )
            our_path = joinpath(
                "packages",
                "$(uppercase(name[1:1]))",
                "$(name)",
                )
            our_full_path = joinpath(project_root, our_path)
            if isdir(our_full_path) || ispath(our_full_path)
                error(
                    string(
                        "The directory $(our_path) already exists at ",
                        "$(our_full_path). ",
                        "Please delete that directory and try again.",
                        )
                    )
            else
                rm(
                    our_full_path;
                    force = true,
                    recursive = true,
                    )
                mkpath(our_full_path)
                our_compat_toml =joinpath(our_full_path, "Compat.toml")
                our_deps_toml=joinpath(our_full_path, "Deps.toml")
                our_package_toml=joinpath(our_full_path, "Package.toml")
                our_versions_toml=joinpath(our_full_path, "Versions.toml")
                their_compat_toml=joinpath(their_full_path, "Compat.toml")
                their_deps_toml=joinpath(their_full_path, "Deps.toml")
                their_package_toml=joinpath(their_full_path, "Package.toml")
                their_versions_toml=joinpath(their_full_path, "Versions.toml")
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
                this_registry_configuration["packages"][their_uuid] = Dict(
                    "name" => name,
                    "path" => our_path,
                    )
                push!(info_messages, "Added $(name)")
            end
        end
    else
        error(
            string(
                "The external registry does not have the package ",
                "\"$(name)\" ",
                "in their registry.",
                )
            )
    end
end

empty!(Base.DEPOT_PATH)
for x in original_depot_path
    push!(Base.DEPOT_PATH, x,)
end
unique!(Base.DEPOT_PATH)

rm(this_registry_toml_path; force = true, recursive = true)
open(this_registry_toml_path, "w") do f
    Pkg.TOML.print(f, this_registry_configuration)
end
push!(info_messages, "Wrote Registry.toml file to $(this_registry_toml_path)")

for message in info_messages
    @info(message)
end

cd(original_directory)
