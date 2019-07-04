# BCBIRegistry

<a
href="https://travis-ci.org/bcbi/BCBIRegistry/branches">
<img
src="https://travis-ci.org/bcbi/BCBIRegistry.svg?branch=master"/>
</a>

This is the official Julia package registry for the [Brown Center for Biomedical Informatics](https://github.com/bcbi).

## 1. Usage

### 1.1. Adding BCBIRegistry

To add BCBIRegistry, open Julia and run the following commands:

```julia
import Pkg; 
Pkg.Registry.add(Pkg.RegistrySpec(name="BCBIRegistry",url="https://github.com/bcbi/BCBIRegistry.git",uuid="26a550a3-39fe-4af4-af6d-e8814c2b6dd9",)); 
Pkg.Registry.update("BCBIRegistry"); 
```

### 1.2. Adding the General registry

Packages registered in BCBIRegistry often have dependencies that are registered in the [General](https://github.com/JuliaRegistries/General) registry (but are not registered in BCBIRegistry). Therefore, you will probably want to make sure that you have also added the General registry. To add the General registry, open Julia and run the following commands:

```julia
import Pkg; 
Pkg.add("General"); 
Pkg.update("General"); 
```

### 1.3. Updating registries

To update all of the registries that you have added, open Julia and run the following commands:
```julia
import Pkg; 
Pkg.update(); 
```

To update a specific registry, pass that registry as the argument to `Pkg.update`.

For example, to update BCBIRegistry, open Julia and run the following commands:
```julia
import Pkg; 
Pkg.update("BCBIRegistry"); 
```

As another example, to update the General registry, open Julia and run the following commands:
```julia
import Pkg; 
Pkg.update("General"); 
```

## 2. How to register a new package with BCBIRegistry

See [CONTRIBUTING.md](CONTRIBUTING.md) for instructions.

## 3. How to tag a new release for a package already registered with BCBIRegistry

See [CONTRIBUTING.md](CONTRIBUTING.md) for instructions.

## 4. How to overwrite the files in BCBIRegistry with the files in the General registry

From time to time, you may want to "reset" BCBIRegistry to match the [General registry](https://github.com/JuliaRegistries/General). In order to do this, you simply need to delete the relevant files in BCBIRegistry and replace them with the corresponding files in the General registry. The quickest way to accomplish this is by using the `overwrite_from_external_registry.jl` script.

The syntax is:
```bash
julia overwrite_from_external_registry.jl "EXTERNAL_REGISTRY_NAME" "EXTERNAL_REGISTRY_UUID" "EXTERNAL_REGISTRY_URL" [list of packages or interval of packages (optional)]
```

Examples:

1. To reset ALL packages in the BCBIRegistry to match the Julia General registry:
```bash
julia overwrite_from_external_registry.jl "General" "23338594-aafe-5451-b93e-139f81909106" "https://github.com/JuliaRegistries/General.git"
```

2. To reset only the `Foo` package:
```bash
julia overwrite_from_external_registry.jl "General" "23338594-aafe-5451-b93e-139f81909106" "https://github.com/JuliaRegistries/General.git" "Foo"
```

3. To reset the `Foo`, `Bar`, and `Baz` packages:
```bash
julia overwrite_from_external_registry.jl "General" "23338594-aafe-5451-b93e-139f81909106" "https://github.com/JuliaRegistries/General.git" "Foo" "Bar" "Baz"
```
