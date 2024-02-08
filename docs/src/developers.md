# Developers
* (Optional) `just` taskrunner, see [Justfile](@ref), install as a dev tool as a convenience.
* From repo root type '`just info`' for hints.
* Documenter.jl `doctest()` included in `runtests.jl`

## Test, Build Docs with Justfile
!!! note "Note"
    Assumes local Prefect test db was installed and running, see [Prefect Installation](@ref).

```bash
$ cd ./PrefectInterfaces

$ just build

Test Summary:                 | Pass  Total  Time
All tests                     |   95     95  9.0s
  Config                      |    9      9  0.4s
  Block types, function tests |   58     58  1.8s
  Dataset function            |   27     27  0.5s
  Doctests: PrefectInterfaces |    1      1  5.8s

     Testing PrefectInterfaces tests passed

# docs only: build/doctest
just docs

# review the docs locally
open ./docs/build/index.html
```

## Run Tests from Command Line
```bash
# launch the local prefect server if its not available
cd ./prefect
just launch

cd ./PrefectInterfaces
PREFECT_API_URL="http://127.0.0.1:4300/api" julia --debug-info=2 --project=. \
    --startup-file=no --eval 'import Pkg; Pkg.test()'

# SERVER HEALTH CHECK #
# =================== #
Active Prefect Environment: main
┌ Info: Prefect Server must be running, i.e. `prefect server start`
│ Calling http://127.0.0.1:4300/api/health
└ Server reponse status: 200 OK

Test Summary:                 | Pass  Total  Time
All tests                     |   94     94  2.7s
  Config                      |    9      9  0.4s
  Block types, function tests |   58     58  1.8s
  Dataset function            |   27     27  0.5s

     Testing PrefectInterfaces tests passed
```

## REPL
`$ julia --project=.`

```julia
pkg> activate .
pkg> test
```
