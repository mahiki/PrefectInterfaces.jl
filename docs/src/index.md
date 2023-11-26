# PrefectInterfaces.jl
>May the Prefect Julia SDK arrive soon.

You prefer to analyze and wrangle data in Julia, and you orchestrate your data workflows with Prefect (in python), this project helps you bring those together.

**PrefectInterfaces.jl** helps you integrate Julia operations into a Prefect orchestration environment. Julia functions call your Prefect instance (Server or Cloud) and pull block information including secrets. Now you can use Prefect python flows to call your Julia process via `DockerContainer` or `ShellOperation` and deploy these in the normal way. The Julia process has access to resources and can read/write in the same environment as the rest of your orchestration code.

Included in the package is a bootstrapped installation of a local Prefect instance, and an example `Dataset` type to demonstrate a concrete use-case.

## Installation
!!! note "Requires a Prefect Instance"
    To use most functionality, a Prefect server/cloud instance must be available. Provide the API endpoint via environment variable `PREFECT_API_URL` or set the definition within julia application code. If authenticating to Prefect Cloud, or if your server instances has an authentication key, you will also need `PREFECT_API_KEY`. See [PrefectAPI](@ref).

    See [Prefect Installation](@ref) to quickly launch a local Prefect server.

```julia
julia> Pkg.add("PrefectInterfaces")
```
## Usage
* List available Prefect blocks
* Load a secret from the Prefect DB
* Load a local file system block from Prefect DB
* Use the `read_path`, `write_path` methods from the FS Block.
    * Notice the block implements a base path

!!! note "Read/Write Assumes CSV Data"
    `read_path/write_path`, and also the `Dataset` read/write methods, currently support read/read via `CSV` module. In the future this should be refactored to handle any type of file.

```julia
# provide a reference to the running Prefect REST API
julia> ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api"

using PrefectInterfaces

db = ls();
db.blocks
    # 3-element Vector{String}:
    #  "local-file-system/willowdata"
    #  "secret/necromancer"
    #  "string/syrinx"

secret_block = PrefectBlock("secret/necromancer")
# PrefectBlock("secret/necromancer", Main.PrefectInterfaces.SecretBlock("secret/necromancer", "secret", ####Secret####))

secret_block.block.value
    #  ####Secret####

secret_block.block.value.secret
    # "abcd1234"

using DataFrames
df = DataFrame(
    flag = [false, true, false, true, false, true]
    , amt = [19.00, 11.00, 35.50, 32.50, 5.99, 5.99]
    , qty = [1, 4, 1, 3, 21, 109]
    , item = ["B001", "B001", "B020", "B020", "BX00", "BX00"]
    , day = ["2021-01-01", "2021-01-01", "2112-12-12", "2020-10-20", "2021-05-04", "1984-07-04"]
    );

fs_block = PrefectBlock("local-file-system/willowdata");
dump(fs_block)
    # PrefectBlock
    #   blockname: String "local-file-system/willowdata"
    #   block: LocalFSBlock
    #     blockname: String "local-file-system/willowdata"
    #     blocktype: String "local-file-system"
    #     basepath: String "$HOME/willowdata/main"
    #     read_path: #4 (function of type PrefectInterfaces.var"#4#6"{String})
    #       basepath: String "$HOME/willowdata/main"
    #     write_path: #5 (function of type PrefectInterfaces.var"#5#7"{String})
    #       basepath: String "$HOME/willowdata/main"

datafile = fs_block.block.write_path("csv/dataset=test_block_write/data.csv", df)
    # "$HOME/willowdata/main/csv/dataset=test_block_write/data.csv"

isfile(datafile)
    # true

df2 = fs_block.block.read_path("csv/dataset=test_block_write/data.csv")
    # 6×5 DataFrame
    #  Row │ flag   amt      qty    item     day
    #      │ Bool   Float64  Int64  String7  Date
    # ─────┼────────────────────────────────────────────
    #    1 │ false    19.0       1  B001     2021-01-01
    #    2 │  true    11.0       4  B001     2021-01-01
    #    3 │ false    35.5       1  B020     2112-12-12
    #    4 │  true    32.5       3  B020     2020-10-20
    #    5 │ false     5.99     21  BX00     2021-05-04
    #    6 │  true     5.99    109  BX00     1984-07-04
```

## Datasets
On top of the Prefect API, this package includes a **Datasets** module that reads/writes dataframes to file locations based only on the name you give to the data artifact, see [Dataset Type](@ref).

## Calling From Prefect Flow
The one thing the Julia process will need from the prefect flow is the `PREFECT_API_URL` (and `PREFECT_API_KEY` if using Prefect Cloud). This is accessible from your Prefect python application code via settings. The call to Julia code is via `ShellOperation` or Docker container.

```py
# Python
from prefect import flow
from prefect_shell import ShellOperation
from prefect import settings
prefect_api = settings.PREFECT_API_URL.value()
    # 'http://127.0.0.1:4300/api'

@flow(log_prints=True)
call_julia_script(prefect_api_url_arg=prefect_api):
    result = ShellOperation(
        stream_output=True
        , command=["julia --project=. --load path/to/julia-script.jl"]
        , working_dir="path/to/whatever"
        , env={"PREFECT_API_URL": prefect_api_url_arg}
        ).run()
```

So can pass the Prefect API endpoint to your `Docker` or `ShellOperation` either as an env variable or parameter to the julia command.


----------
For more detailed design discussion, including "why not PythonCall/JuliaCall", see [Usage and Design Explanation](@ref).
