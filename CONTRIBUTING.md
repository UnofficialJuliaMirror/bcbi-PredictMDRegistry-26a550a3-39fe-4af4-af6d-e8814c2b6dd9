<table>
    <thead>
        <tr>
            <th>Table of Contents</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td align="left">
                <a href="#1-how-to-submit-a-new-package-to-bcbiregistry">
                    1. How to submit a new package to BCBIRegistry
                </a>
            </td>
        </tr>
        <tr>
            <td align="left">
                <a href="#2-how-to-tag-a-new-release-for-a-package-already-registered-with-bcbiregistry">
                    2. How to tag a new release for a package already registered with BCBIRegistry
                </a>
            </td>
        </tr>
        <tr>
            <td align="left">
                <a href="#see-also">
                    See Also
                </a>
            </td>
        </tr>
    </tbody>
</table>

# 1. How to submit a new package to BCBIRegistry

## Step 1:

Tag a new release of your package.
For this document, we will call the package `Example.jl`.

## Step 2:

Make your own fork of this repo: [https://github.com/bcbi/BCBIRegistry/fork](https://github.com/bcbi/BCBIRegistry/fork)

## Step 3:

`cd` to a temporary directory.

## Step 4:

Clone your fork:

```bash
git clone git@github.com:YourGitHubUsername/BCBIRegistry.git
```

## Step 5:

`cd` into your cloned fork:
```bash
cd BCBIRegistry
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
mkdir -p packages/E/Example
```

## Step 8:

`cd` into the newly created directory for your package:
```bash
cd packages/E/Example
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

Go to your package and run the following commands:
```bash
git checkout tags/MY-GIT-TAG
git log --pretty=format:'%T %s' | head -n 1
```

For example, to get the `git-tree-sha` value for version `v1.2.3`, you would do:
```bash
git checkout tags/v1.2.3
git log --pretty=format:'%T %s' | head -n 1
```

## Step 11:

Go back to the root directory and add your package to `Registry.toml`:
```bash
cd ../../..
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

Open a new pull request: [https://github.com/bcbi/BCBIRegistry/compare](https://github.com/bcbi/BCBIRegistry/compare)

## Step 15:

Once your pull request has been merged, delete your local copy of your fork:
```bash
rm -rf BCBIRegistry
```

# 2. How to tag a new release for a package already registered with BCBIRegistry

## Step 1:

Tag a new release of your package.
For this document, we will call the package `Example.jl`.

## Step 2 (if you don't already have your own fork):

If you don't already have your own fork of this repo, make a fork: [https://github.com/bcbi/BCBIRegistry/fork](https://github.com/bcbi/BCBIRegistry/fork)

## Step 3:

`cd` to a temporary directory.

## Step 4:

Clone your fork:

```bash
git clone git@github.com:YourGitHubUsername/BCBIRegistry.git
```

## Step 5:

`cd` into your cloned fork:
```bash
cd BCBIRegistry
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
cd packages/E/Example
```

## Step 8:

Update the files appropriately.

- `Compat.toml`
- `Deps.toml`
- `Package.toml`
- `Versions.toml`

### How to get the `git-tree-sha` value for a tagged version

Go to your package and run the following commands:
```bash
git checkout tags/MY-GIT-TAG
git log --pretty=format:'%T %s' | head -n 1
```

For example, to get the `git-tree-sha` value for version `v1.2.3`, you would do:
```bash
git checkout tags/v1.2.3
git log --pretty=format:'%T %s' | head -n 1
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

Open a new pull request: [https://github.com/bcbi/BCBIRegistry/compare](https://github.com/bcbi/BCBIRegistry/compare)

## Step 12:

Once your pull request has been merged, delete your local copy of your fork:
```bash
rm -rf BCBIRegistry
```

# See Also

## Helpful documentation and discussions

1. [https://github.com/HolyLab/HolyLabRegistry/blob/master/README.md](https://github.com/HolyLab/HolyLabRegistry/blob/master/README.md)
2. [Creating a registry](https://discourse.julialang.org/t/creating-a-registry/12094)

## Examples of other registries

1. [https://github.com/HolyLab/HolyLabRegistry](https://github.com/HolyLab/HolyLabRegistry)
2. [https://github.com/fredrikekre/Registry](https://github.com/fredrikekre/Registry)
