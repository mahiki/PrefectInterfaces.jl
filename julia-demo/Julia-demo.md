# PrefectInterfaces - Commands That Call a Running Prefect Server
```sh
cd ./prefect/
just launch

    # to verify server is running, and the API PORT:
    just view main
    # CTRL-b, d to exit

cd ../julia-demo

# start julia in current project, env vars will be loaded as well
just julia

# alternately, this justfile script will load the ENV variables:
```

## EXAMPLES
TODO: Below we add the repo URL manually, as PrefectInterfaces is not registered yet.

```julia
# go into Pkg mode
] status
pkg> add https://github.com/mahiki/PrefectInterfaces.jl.git
pkg> instantiate

# back to julia prompt
julia> using PrefectInterfaces

PrefectAPI().url
    # "http://127.0.0.1:4300/api"

# list all the blocks currently loaded in the Prefect DB
db = ls()
(blocks = ["local-file-system/willowdata", "string/syrinx"],)

# now lets try loading the block information from the Prefect server:
env = PrefectBlock("string/syrinx");
env.block.value
    # "main"

# The prefect LocalFileSystemBlock helps us read/write to a local filesystem
fs = PrefectBlock(db.blocks[1]);
dump(fs)
    # PrefectBlock
    #   blockname: String "local-file-system/willowdata"
    #   block: LocalFSBlock
    #     blockname: String "local-file-system/willowdata"
    #     blocktype: String "local-file-system"
    #     basepath: String "<HOME>/willowdata/main"
    #     read_path: #4 (function of type PrefectInterfaces.var"#4#6"{String})
    #       basepath: String "<HOME>/willowdata/main"
    #     write_path: #5 (function of type PrefectInterfaces.var"#5#7"{String})
    #       basepath: String "<HOME>/willowdata/main"

using DataFrames
df = DataFrame(flag = [false, true, false, true, false, true]
    , amt = [19.00, 11.00, 35.50, 32.50, 5.99, 5.99]
    , qty = [1, 4, 1, 3, 21, 109]
    , ship = [.50, .50, 1.50, .55, 0.0, 1.99]
    , item = ["B001", "B001", "B020", "B020", "BX00", "BX00"]
    , day = ["2021-01-01", "2021-01-01", "2112-12-12", "2020-10-20", "2021-05-04", "1984-07-04"]
    );

# The LocalFSBlock type has a `write_path` method that writes to the local location
#   defined by the block 'local-file-system/willowdata'

fs.block.write_path("test_write_df/data.csv", df)
    # "<HOME>/willowdata/main/test_write_df/data.csv"

df2 = fs.block.read_path("test_write_df/data.csv")
    # 6×6 DataFrame
    #  Row │ flag   amt      qty    ship     item     day
    #      │ Bool   Float64  Int64  Float64  String7  Date
    # ─────┼─────────────────────────────────────────────────────
    #    1 │ false    19.0       1     0.5   B001     2021-01-01
    #    2 │  true    11.0       4     0.5   B001     2021-01-01
    #    3 │ false    35.5       1     1.5   B020     2112-12-12
    #    4 │  true    32.5       3     0.55  B020     2020-10-20
    #    5 │ false     5.99     21     0.0   BX00     2021-05-04
    #    6 │  true     5.99    109     1.99  BX00     1984-07-04
```

There are other `AbstractPrefectBlock` types, see list below. These facilitate interactions with Blocks in your Prefect instance, they are primary organizing abstractions in the Prefect world.

```julia
julia> names(PrefectInterfaces);
subtypes(PrefectInterfaces.AbstractPrefectBlock)
    #    AWSCredentialsBlock
    #    CredentialPairBlock
    #    LocalFSBlock
    #    PrefectBlock
    #    S3BucketBlock
    #    StringBlock
```

## DATASET TYPE
This type is an opinionated means of organizing data artifacts by name.  This is not a part of the Prefect API, and can be disregarded. Dataset is not a dependency of the Prefect types that are meant to constitute an unofficial 'Prefect Julia SDK'.

This is a lightweight organizational construct for reading/writing data artifacts as a part of orchestrated data pipelines. The type merely holds metadata about named data sets and where they should be found or placed in a file system that is defined by a Prefect Block. The data files get arranged in a hive-ish file structure that allows tracking experiment results or daily extracts.

The fields of the Dataset type are populated by env variables (loaded from a `.env` file) or defined in the constructor.

```julia
ds = Dataset(dataset_name="test_dataset_table", datastore_type="local")

write(ds, df)
    # "<HOME>/willowdata/main/extracts/csv/latest/dataset=test_dataset_table/data.csv"

df3 = read(ds)
    # 6×6 DataFrame
    # Row │ flag   amt      qty    ship     item     day
    #     │ Bool   Float64  Int64  Float64  String7  Date
    #─────┼─────────────────────────────────────────────────────
    #   1 │ false    19.0       1     0.5   B001     2021-01-01
    #   2 │  true    11.0       4     0.5   B001     2021-01-01
    #   3 │ false    35.5       1     1.5   B020     2112-12-12
    #   4 │  true    32.5       3     0.55  B020     2020-10-20
    #   5 │ false     5.99     21     0.0   BX00     2021-05-04
    #   6 │  true     5.99    109     1.99  BX00     1984-07-04

df3 == df2
    # true
```

That demonstrates the basic functionality of PrefectInterfaces types that can be constructed from the data stored in Prefect blocks.

Shut down the server.

    cd ../prefect
    just kill

----------
## EPILOGUE
**NOTE ABOUT ENV**: The Prefect types pull information from a running Prefect DB, by calling the REST API at env variable PREFECT_API_URL. If the julia REPL session is called from a `just` command, the .env variables will be exported into the environment. In application code you need to either set `ENV["PREFECT_API_URL"]="http://127.0.0.1:4300/api"` or use the `ConfigEnv` package as shown below.

```jl
# Without using 'just' commands, you can load the .env file this way
using ConfigEnv

dotenv(".env"; overwrite = false);

ENV["PREFECT_REMOTE_DATA_BLOCK"]
    # "s3-bucket/willowdata"
```

The variable PREFECT_REMOTE_DATA_BLOCK is used by the `PrefectDatastoreType` to return the names of your Prefect blocks which define remote or local storage.