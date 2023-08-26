# PrefectInterfaces.jl 
[![Stable](https://img.shields.io/badge/docs-main-blue.svg)](https://mahiki.github.io/PrefectInterfaces.jl) [![Build Status](https://github.com/mahiki/PrefectInterfaces.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mahiki/PrefectInterfaces.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/mahiki/PrefectInterfaces.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/mahiki/PrefectInterfaces.jl)

>May the official Prefect Julia SDK arrive soon.

This is a small package that helps you connect to a Prefect instance from a Julia process. This enables integrating your Julia code into your existing workflow orchestration managed by Prefect. Included in the package is a bootstrapped installation of a local Prefect instance, and an example `Dataset` type to demonstrate a concrete use-case.

## Installation
```julia
julia> Pkg.add("PrefectInterfaces")
```

## Usage
* A Prefect server/cloud instance must be available via API URL to use these functions, the examples below are hypothetical and require a running Prefect server with blocks registered in the names below.
* See [Prefect local installation instructions.](docs/src/prefect/install-local-prefect-environment.md)

```julia
# provide a reference to the running Prefect REST API
julia> ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api"

using PrefectInterfaces

# retrieve the names of blocks from your running Prefect instance
db = ls();
db.blocks
    # 3-element Vector{String}:
    #  "local-file-system/willowdata"
    #  "secret/necromancer"
    #  "string/syrinx"

secret_block = PrefectBlock("secret/necromancer")
# PrefectBlock("secret/necromancer", Main.PrefectInterfaces.SecretBlock("secret/necromancer", "secret", ####Secret####))

secret_block.block.value.secret
    # "abcd1234"
```
