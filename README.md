# PredictMDRegistry

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
            <td><a href="https://travis-ci.org/bcbi/PredictMDRegistry/branches">
            <img
            src="https://travis-ci.org/bcbi/PredictMDRegistry.svg?branch=master"
            /></a></td>
        </tr>
    </tbody>
</table>

This is a Julia package registry for [PredictMD](https://predictmd.net)
and PredictMD-related packages.

# Usage

```julia
import Pkg; 
Pkg.Registry.add(Pkg.RegistrySpec(name="PredictMDRegistry",url="https://github.com/bcbi/PredictMDRegistry.git",uuid="26a550a3-39fe-4af4-af6d-e8814c2b6dd9",)); 
Pkg.Registry.update(Pkg.RegistrySpec(name="PredictMDRegistry",uuid="26a550a3-39fe-4af4-af6d-e8814c2b6dd9")); 
```

# How to register a new package with PredictMDRegistry

See [CONTRIBUTING.md](CONTRIBUTING.md) for instructions.
