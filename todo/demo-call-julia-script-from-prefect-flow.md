# Demo: Call a Julia script from Prefect flow

TODO: add prefect-shell to poetry project dependencies
TODO: make this a working demo from a prefect flow.

    PrefectInterfaces/prefect/src/call_julia_script.py
    PrefectInterfaces/prefect/src/example_julia_script.jl

Example command from the poetry python environment. Run the Prefect flow with ShellOp call to julia script.

## USAGE
From the `PrefectInterfaces/prefect` directory:

```sh
just run poetry run python src/call_julia_script.py
```