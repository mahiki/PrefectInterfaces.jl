# Developers
Develop and test with 

```bash
# launch the local prefect server if its not available
cd ./prefect
just launch

cd ./PrefectInterfaces
julia --project=. --startup-file=no --eval 'import Pkg; Pkg.test()'
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

Alternately, using the `justfile`
```julia
cd .../PrefectInterfaces

just test
```

Or, from the REPL:

`julia --project=.`
```julia
pkg> activate .
pkg> test
```
