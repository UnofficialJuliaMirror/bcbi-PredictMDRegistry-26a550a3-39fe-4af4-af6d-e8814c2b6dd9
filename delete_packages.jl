import Pkg

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

this_registry_toml_path = joinpath(project_root, "Registry.toml")
this_registry_configuration = Pkg.TOML.parsefile(this_registry_toml_path)
if !haskey(this_registry_configuration, "packages")
    this_registry_configuration["packages"] = Dict{String,Any}()
end

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

packages_to_force_delete = String[
    strip(s) for s in ARGS
    ]

unique!(packages_to_force_delete)
sort!(packages_to_force_delete)
@debug(
    "packages_to_force_delete",
    length(packages_to_force_delete),
    packages_to_force_delete,
    repr(packages_to_force_delete),
    )

info_messages = Vector{String}(undef, 0)
n = length(packages_to_force_delete)
for i = 1:n
    name = packages_to_force_delete[i]
    @debug("Deleting \"$(name)\" (package $(i) of $(n))")
    if name in this_registry_all_packages
        our_uuid = this_registry_name_to_uuid[name]
        our_path = this_registry_name_to_path[name]
        our_full_path = joinpath(project_root, our_path)
        rm(our_full_path; force = true, recursive = true)
        delete!(this_registry_configuration["packages"], our_uuid)
    end
    our_hypothetical_path_uppercase = joinpath(
        "packages",
        "$(uppercase(name[1:1]))",
        "$(name)",
        )
    our_hypothetical_path_lowercase = joinpath(
        "packages",
        "$(lowercase(name[1:1]))",
        "$(name)",
        )
    our_full_hypothetical_path_uppercase = joinpath(
        project_root,
        our_hypothetical_path_uppercase,
        )
    our_full_hypothetical_path_lowercase = joinpath(
        project_root,
        our_hypothetical_path_lowercase,
        )
    rm(our_full_hypothetical_path_uppercase; force = true, recursive = true)
    rm(our_full_hypothetical_path_lowercase; force = true, recursive = true)
    push!(info_messages, "Deleted $(name) from our registry")
end

rm(this_registry_toml_path; force = true, recursive = true)
open(this_registry_toml_path, "w") do f
    Pkg.TOML.print(f, this_registry_configuration)
end

temp_registry_toml = read(this_registry_toml_path, String)
temp_registry_toml_parsed = Pkg.TOML.parse(temp_registry_toml)
if !haskey(temp_registry_toml_parsed, "packages")
    temp_output = string(temp_registry_toml,
                         "\n\n\n\n",
                         "[packages]",
                         "\n\n\n\n")
    rm(this_registry_toml_path; force = true, recursive = true)
    write(this_registry_toml_path, temp_output)
end

push!(info_messages, "Wrote Registry.toml file to $(this_registry_toml_path)")

for message in info_messages
    @info(message)
end

cd(original_directory)
