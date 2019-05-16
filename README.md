# BCBIRegistry

<a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg" alt="Project Status: Active – The project has reached a stable, usable state and is being actively developed." /></a>

<table>
    <thead>
        <tr>
            <th></th>
            <th>master</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Travis CI</td>
            <td><a href="https://travis-ci.org/bcbi/BCBIRegistry/branches">
            <img
            src="https://travis-ci.org/bcbi/BCBIRegistry.svg?branch=master"
            /></a></td>
        </tr>
    </tbody>
</table>

This is a Julia package registry for [PredictMD](https://predictmd.net)
and PredictMD-related packages.

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
