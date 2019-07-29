import Pkg

original_directory = pwd()
project_root = joinpath(splitpath(@__DIR__)...)
cd(project_root)

include(joinpath(project_root, "ci", "RegistryTestingTools", "types.jl",))

if length(ARGS) == 0
    push!(ARGS, "[,)",)
end

this_registry_toml_path = joinpath(project_root, "Registry.toml")
registry_configuration = Pkg.TOML.parsefile(this_registry_toml_path)
name_to_path = Dict{String, String}()
all_packages = String[]
for pair in registry_configuration["packages"]
    name = pair[2]["name"]
    path = pair[2]["path"]
    push!(all_packages, name,)
    name_to_path[name] = path
end

unique!(all_packages)
sort!(all_packages)
n = length(all_packages)
@debug("all_packages ($(n)):")
for i = 1:n
    @debug("$(i). $(all_packages[i])")
end
if _is_interval(ARGS[1])
    this_job_interval = _construct_interval(
        convert(String, strip(ARGS[1]))
        )
    _this_job_interval_contains_x(x) = _interval_contains_x(
        this_job_interval,
        x,
        )
    packages_to_compress_in_this_job_interval = all_packages[
        _this_job_interval_contains_x.(
            all_packages
            )
        ]
else
    packages_to_compress_in_this_job_interval = String[
        strip(s) for s in ARGS
        ]
end
unique!(packages_to_compress_in_this_job_interval)
sort!(packages_to_compress_in_this_job_interval)
n = length(packages_to_compress_in_this_job_interval)
@debug("packages_to_compress_in_this_job_interval ($(n)):")
for i = 1:n
    @debug("$(i). $(packages_to_compress_in_this_job_interval[i])")
end

n = length(packages_to_compress_in_this_job_interval)
for i = 1:n
    name = packages_to_compress_in_this_job_interval[i]
    @debug("Compressing \"$(name)\" (package $(i) of $(n))")
    path = name_to_path[name]
    for j = 1:3
        for filename in ["Versions.toml", "Compat.toml", "Deps.toml",]
            full_file_path = joinpath(path, filename,)
            uncompressed = Pkg.Compress.load(full_file_path,)
            Pkg.Compress.save(full_file_path,uncompressed,)
        end
    end
    @info("Compressed package \"$(name)\"")
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

cd(original_directory)
