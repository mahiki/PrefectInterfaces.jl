# PrefectInterfaces.jl
>May the Prefect Julia SDK arrive soon.

You prefer to analyze and wrangle data in Julia, and you orchestrate your data workflows with Prefect (in python).

PrefectInterfaces.jl helps you integrate Julia operations into a Prefect orchestration environment. Julia functions call your Prefect instance (Server or Cloud) and pull block information including secrets. Now you can use Prefect python flows to call your Julia process via `DockerContainer` or `ShellOperation` and deploy these in the normal way. The Julia process has access to resources and can read/write in the same environment as the rest of your orchestration code.


## INSTALLATION
* A Prefect server/cloud instance must be available via API URL to use these functions.
* See [Prefect local installation instructions here.](prefect/README.md)

```julia
# Package is not yet registered
julia> Pkg.add("https://github.com/mahiki/PrefectInterfaces.jl")
```
## USAGE
>These demo commands will work with the included prefect installation, [see Prefect installation instructions](prefect/README.md)

* List available Prefect blocks
* Load a secret from the Prefect DB
* Load a local file system block from Prefect DB
* Use the `read_path`, `write_path` methods from the FS Block.
    * Notice the block implements a base path
    * *NOTE:* these are defaulting to read/read via `CSV` module. That should get fixed to handle any type of file.

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

## CALLING FROM PREFECT FLOW
The one thing the Julia process will need from the prefect flow is the PREFECT_API_URL. This is accessible from your Prefect application code via settings:

```py
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

So you'll pass this to your `Docker` or `ShellOperation` either as an env variable or parameter to the julia command.


----------
More detailed design discussion, including why not `PythonCall/JuliaCall` in [Usage Explanation](info/Usage-and-Explanation.md).
