# BCBIRegistry


<a
href="https://travis-ci.org/bcbi/BCBIRegistry/branches">
<img
src="https://travis-ci.org/bcbi/BCBIRegistry.svg?branch=master"/>
</a>

This is the official Julia package registry for the [Brown Center for Biomedical Informatics](https://github.com/bcbi).

# Usage

## Adding BCBIRegistry

To add BCBIRegistry, open Julia and run the following commands:

```julia
import Pkg; 
Pkg.Registry.add(Pkg.RegistrySpec(name="BCBIRegistry",url="https://github.com/bcbi/BCBIRegistry.git",uuid="26a550a3-39fe-4af4-af6d-e8814c2b6dd9",)); 
Pkg.Registry.update(Pkg.RegistrySpec(name="BCBIRegistry",uuid="26a550a3-39fe-4af4-af6d-e8814c2b6dd9")); 
```

## Adding the General registry

Packages registered in BCBIRegistry often have dependencies that are registered in the [General](https://github.com/JuliaRegistries/General) registry (but are not registered in BCBIRegistry). Therefore, you will probably want to make sure that you have also added the General registry. To add the General registry, open Julia and run the following commands:

```julia
import Pkg; 
Pkg.add("General"); 
Pkg.update("General"); 
```

## Updating registries

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

# How to register a new package with BCBIRegistry

See [CONTRIBUTING.md](CONTRIBUTING.md) for instructions.

# How to tag a new release for a package already registered with BCBIRegistry

See [CONTRIBUTING.md](CONTRIBUTING.md) for instructions.
