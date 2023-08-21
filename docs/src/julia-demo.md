# Julia Demo
This demonstrates interacting with a running Prefect DB from the Julia REPL. If you don't have a Prefect Server instance running, see the [Prefect Installation](@ref) doc first. Block information is usually pulled from the Prefect DB, but Prefect Block types can also be manually created from the constructors.

See files in the `test` folder for examples of Block usage and loading data from Prefect DB, some require the Prefect DB to run and some tests simply construct dummy objects without connecting to Prefect.

Entering the Julia REPL from the `just julia` command will inject the `.env` variables. Execute the `just` commands from the appropriate directory as shown.
```sh
$ cd ./prefect/
$ just launch

    # to verify server is running, and the API PORT:
    just view main
    # CTRL-b, d to exit

$ cd ../julia-demo

# start julia in current project, env vars will be loaded as well
$ just julia
```

## Examples
* Call the `PrefectAPI` function
* Access the secret string in an AWS Credentials block via `.secret` field
  
```julia
# julia> go into Pkg mode
] status
pkg> add https://github.com/mahiki/PrefectInterfaces.jl
pkg> instantiate

# back to julia prompt
julia> using PrefectInterfaces

# returns the default from env
PrefectAPI().url
    # "http://127.0.0.1:4300/api"

PrefectAPI("http://127.0.0.1:4444/api").url
    # "http://127.0.0.1:4444/api"

# PrefectAPI is called by various functions to retreive the current API env value
ENV["PREFECT_API_URL"] = "http://127.0.0.1:4301/api";
PrefectAPI().url
    # "http://127.0.0.1:4301/api"

# Construct an example, normally this is pulled from DB if such a block 
#   exists with PrefectBlock("aws-credentials/subdivisions")
creds = AWSCredentialsBlock(
    "aws-credentials/subdivisions"
    , "aws-credentials"
    , "us-west-2"
    , "AKIAXXX999XXX999"
    , "GUUxx87987xxPXH")
AWSCredentialsBlock("aws-credentials/subdivisions", "aws-credentials", "us-west-2", "AKIAXXX999XXX999", ####Secret####)

creds.aws_secret_access_key
####Secret####

creds.aws_secret_access_key.secret
"GUUxx87987xxPXH"
```
The secret is obfuscated, to prevent it being visible in logs. 

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
    #    SecretBlock
```

Shut down the server after exiting julia.
```sh
$ cd ../prefect
$ just kill
```


## Dataset Type
This type is an opinionated means of organizing data artifacts by name.  This is not a part of the Prefect API, and can be disregarded. Dataset is not a dependency of the Prefect types that are meant to constitute an unofficial 'Prefect Julia SDK'.

This is a lightweight organizational construct for reading/writing data artifacts as a part of orchestrated data pipelines. The type merely holds metadata about named data sets and where they should be found or placed in a file system that is defined by a Prefect Block. The data files get arranged in a hive-ish file structure that allows tracking experiment results or daily extracts. The layout assumes partitions of daily data, additing additional partitions to the struct definition wouldn't be difficult.

The fields of the Dataset type are populated by env variables (loaded from a `.env` file) or defined in the constructor. The env variables `PREFECT_DATA_BLOCK_REMOTE`, `PREFECT_DATA_BLOCK_LOCAL` are used by the `PrefectDatastoreNames()` to return the names of your Prefect blocks which define remote or local storage.

```julia
ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api"
ENV["PREFECT_DATA_BLOCK_LOCAL"] = "local-file-system/willowdata"
ENV["PREFECT_DATA_BLOCK_REMOTE"] = "local-file-system/willowdata"   
     # NOTE: defining the same, unless you have a remote storage block registered

ds = Dataset(dataset_name="limelight_moving_pictures", datastore_type="local")

using DataFrames
df = DataFrame(
    flag = [false, true, false, true, false, true]
    , amt = [19.00, 11.00, 35.50, 32.50, 5.99, 5.99]
    , qty = [1, 4, 1, 3, 21, 109]
    , item = ["B001", "B001", "B020", "B020", "BX00", "BX00"]
    , day = ["2021-01-01", "2021-01-01", "2112-12-12", "2020-10-20", "2021-05-04", "1984-07-04"]
    );

write(ds, df)
    #  "$HOME/willowdata/main/extracts/csv/latest/dataset=limelight_moving_pictures/data.csv"
    #  "$HOME/willowdata/main/extracts/csv/dataset=limelight_moving_pictures/rundate=2023-08-14/data.csv"

dfr = read(ds)
    # 6×5 DataFrame
    #  Row │ flag   amt      qty    item     day
    #  ... etc
```

The `read` and `write` functions are calling the Prefect Server API to retrieve block information, in this case the `LocalFilesystem.basepath` attribute.

Notice the `write` function writes to two locations unless `rundate_type="specific"`. This is for the use-case of running a backfill of historical daily data without affecting the 'latest' path. The 'latest' folder is a convenience rather than creating a module that reads file metdata.
```
tree $HOME/willowdata/main/extracts
$HOME/willowdata/main/extracts
└── csv
    ├── dataset=limelight_moving_pictures
    │   └── rundate=2023-08-14
    │       └── data.csv
    └── latest
        └── dataset=limelight_moving_pictures
            └── data.csv
```

Reading/writing a specific rundate:
```julia
# writing a specific rundate
ds1 = Dataset(dataset_name="test_dataset_specific", datastore_type="local", rundate=Date("2112-03-15"))
    # Dataset
    #   dataset_name: String "test_dataset_specific"
    #   datastore_type: String "local"
    #   dataset_type: String "extracts"
    #   file_format: String "csv"
    #   rundate: Date
    #   rundate_type: String "specific"
    #   dataset_path: String "extracts/csv/dataset=test_dataset_specific/rundate=2112-03-15/data.csv"
    #   latest_path: String "extracts/csv/latest/dataset=test_dataset_specific/data.csv"
    #   image_path: String "extracts/dataset=test_dataset_specific/rundate=2112-03-15"

write(ds1, df)
    #  "$HOME/willowdata/main/extracts/csv/dataset=test_dataset_specific/rundate=2112-03-15/data.csv"

# note only one path was written. the 'latest_path' was not.
shell> ls -la "$HOME/willowdata/main/$(ds1.latest_path)"
    # ls: cannot access '$HOME/willowdata/main/extracts/csv/latest/dataset=test_dataset_specific/data.csv': No such file or directory

shell>  ls -la "$HOME/willowdata/main/$(ds1.dataset_path)"
    # -rw-r--r-- 1 segovia staff 196 Aug 14 15:45 '$HOME/willowdata/main/extracts/csv/dataset=test_dataset_specific/rundate=2112-03-15/data.csv'

# the 'read' function knows to read the correct path
df1 = read(ds1);

df1 == dfr
    # true
```

The datastore now looks like this:
```
/Users/segovia/willowdata/main/extracts/
└── csv
    ├── dataset=test_dataset_specific
    │   └── rundate=2112-03-15
    │       └── data.csv
    ├── dataset=limelight_moving_pictures
    │   └── rundate=2023-08-14
    │       └── data.csv
    └── latest
        └── dataset=limelight_moving_pictures
            └── data.csv
```

----------
## Environment
!!! note "A Note about ENV"
    The Prefect types pull information from a running Prefect DB, by calling the REST API stored in PREFECT_API_URL. If the julia REPL session is called from a `just` command, the .env variables will be exported into the environment. In application code you need to either set `ENV["PREFECT_API_URL"]="http://127.0.0.1:4300/api"` (for example) or use the `ConfigEnv` package as shown below to load the `.env` file from the Julia application.

The `Dataset` read/write functions depend on the local and remote data block names being defined in environment variables.

```julia
# .env file imported with ConfigEnv.dotent(), or just assignment:
using ConfigEnv
dotenv(".env", overwrite=false)

# all the Prefect env variables are now loaded into the Julia environment
ENV["PREFECT_DATA_BLOCK_REMOTE"]
    # "s3-bucket/willowdata"

# or just set them manually
begin
    ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api"
    ENV["PREFECT_DATA_BLOCK_LOCAL"] = "local-file-system/willowdata"
    ENV["PREFECT_DATA_BLOCK_REMOTE"] = "s3-bucket/willowdata"
end
```

For interactive work, entering the Julia REPL from the `just julia` command will inject the `.env` variables.
