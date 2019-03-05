<table>
    <thead>
        <tr>
            <th>Table of Contents</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td align="left">
                <a href="#1-how-to-register-a-new-package-with-predictmdregistry">
                    1. How to register a new package with PredictMDRegistry
                </a>
            </td>
        </tr>
        <tr>
            <td align="left">
                <a href="#2-how-to-register-a-new-version-for-an-existing-package-already-registered-with-predictmdregistry">
                    2. How to register a new version for an existing package already registered with PredictMDRegistry
                </a>
            </td>
        </tr>
        <tr>
            <td align="left">
                <a href="#">
                    
                </a>
            </td>
        </tr>
    </tbody>
</table>

# 1. How to register a new package with PredictMDRegistry

## Step 1:

Tag a new release of your package.
For this document, we will call the package `Example.jl`.

## Step 2:

Make your own fork of this repo: [https://github.com/bcbi/PredictMDRegistry/fork](https://github.com/bcbi/PredictMDRegistry/fork)

## Step 3:

`cd` to a temporary directory.

## Step 4:

Clone your fork:

```bash
git clone git@github.com:YourGitHubUsername/PredictMDRegistry.git
```

## Step 5:

`cd` into your cloned fork:
```bash
cd PredictMDRegistry
```

## Step 6:

Create a new branch and check it out:
```bash
git branch myinitials/registermynewpackage
git checkout myinitials/registermynewpackage
```

## Step 7:

Make a new directory for your package:
```bash
mkdir -p E/Example
```

## Step 8:

`cd` into the newly created directory for your package:
```bash
cd E
cd Example
```

## Step 9:

Create the files `Compat.toml`, `Deps.toml`, `Package.toml`, `Versions.toml`:
```bash
touch Compat.toml
touch Deps.toml
touch Package.toml
touch Versions.toml
```

## Step 10:

Edit the files appropriately.

- `Compat.toml`
- `Deps.toml`: include all the dependencies (can copy lines from the `[deps]` section from the `Project.toml` of your package)
- `Package.toml`
- `Versions.toml`

### How to get the `git-tree-sha` value for a tagged version

Go to your package and run the following command:
```bash
git cat-file -p MY-GIT-TAG
```

For example, to get the `git-tree-sha` value for version `v1.2.3`, you would do:
```bash
git cat-file -p v1.2.3
```

## Step 11:

Go back to the root directory and add your package to `Registry.toml`:
```bash
cd ..
cd ..
vim Registry.toml
```

## Step 12:

Commit your changes:
```bash
git add -A
git commit
```

Enter an appropriate commit message, save, and exit.

## Step 13:

Push your changes up to your fork:

```bash
git push origin myinitials/registermynewpackage
```

## Step 14:

Open a new pull request: [https://github.com/bcbi/PredictMDRegistry/compare](https://github.com/bcbi/PredictMDRegistry/compare)

## Step 15:

Once your pull request has been merged, delete your local copy of your fork:
```bash
rm -rf PredictMDRegistry
```

# 2. How to register a new version for an existing package already registered with PredictMDRegistry

## Step 1:

Tag a new release of your package.
For this document, we will call the package `Example.jl`.

## Step 2 (if you don't already have your own fork):

If you don't already have your own fork of this repo, make a fork: [https://github.com/bcbi/PredictMDRegistry/fork](https://github.com/bcbi/PredictMDRegistry/fork)

## Step 3:

`cd` to a temporary directory.

## Step 4:

Clone your fork:

```bash
git clone git@github.com:YourGitHubUsername/PredictMDRegistry.git
```

## Step 5:

`cd` into your cloned fork:
```bash
cd PredictMDRegistry
```

## Step 6:

Create a new branch and check it out:
```bash
git branch myinitials/updatemypackage
git checkout myinitials/updatemypackage
```

## Step 7:

`cd` into the directory for your package:
```bash
cd E
cd Example
```

## Step 8:

Update the files appropriately.

- `Compat.toml`
- `Deps.toml`
- `Package.toml`
- `Versions.toml`

### How to get the `git-tree-sha` value for a tagged version

Go to your package and run the following command:
```bash
git cat-file -p MY-GIT-TAG
```

For example, to get the `git-tree-sha` value for version `v1.2.3`, you would do:
```bash
git cat-file -p v1.2.3
```

## Step 9:

Commit your changes:
```bash
git add -A
git commit
```

Enter an appropriate commit message, save, and exit.

## Step 10:

Push your changes up to your fork:

```bash
git push origin myinitials/updatemypackage
```

## Step 11:

Open a new pull request: [https://github.com/bcbi/PredictMDRegistry/compare](https://github.com/bcbi/PredictMDRegistry/compare)

## Step 12:

Once your pull request has been merged, delete your local copy of your fork:
```bash
rm -rf PredictMDRegistry
```

# Appendix A: See Also

1. [https://github.com/HolyLab/HolyLabRegistry/blob/master/README.md](https://github.com/HolyLab/HolyLabRegistry/blob/master/README.md)

2. [https://discourse.julialang.org/t/creating-a-registry/12094](https://discourse.julialang.org/t/creating-a-registry/12094)
