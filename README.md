# PrefectInterfaces.jl
>May the Prefect Julia SDK arrive soon.

The problem is to manage routine data ETL or pipeline processing with Prefect and the Python API, while calling Julia fuctions for expressive dataframe transformations or niche high performance custom code. Prefect doesn't provide a Julia SDK (yet), so this package provides components for julia operations that are called from a Prefect orchestration environment. 

Prefect python flows will call Julia `DockerContainer` or `ShellOperations` with parameters such as `{dataset_name: "my_great_dataset", datastore_type: "remote"}`. This isolates the julia environment from the Python one, and avoids sending large data objects through function calls to/from Prefect flows.

This strategy also avoids `pythoncall/juliacall` interoperation, a cool paradigm but one which requires combined python Conda + julia environment management, which is difficult in Prefect deployments. The other side of the coin is that the Julia process needs to define parallel functionality to match the Prefect python application. For example, `PrefectBlock("s3-bucket/willowdata")` which loads block information about `"s3-bucket/willowdata"` from the Prefect server endpoint, or `PrefectInterfaces.Dataset`, which defines a structure for organising input/output/intermediate data file locations to match a similar one in a Prefect application. Accessing block information by name from the julia process greatly simplifies the overall application and reuses the modular paradigm provided by Prefect Blocks.

So now we can orchestrate simple SQL query extracts and data pipelines using the Prefect Python SDK, writing intermediate or final results to a DB or filesystem, and then access these from a julia process using parameters, and references to the same Blocks stored in the Prefect DB. The julia process is orchestrated from Prefect via flow calls to `ShellOperation` or `DockerContainer`. By way of an example implementation, the julia process will read data specified by a `Dataset` instance, and write output to `Dataset` defined locations. This example imaginess a similar `Dataset` class defined in the main python application, it's also an example of the code deplication trade-off mentioned above.

```
┌─────────────┐                   ┌─────────────┐◄───── read ────── ┌───────────┐
│Prefect flow ├────► params ─────►│Julia process├─────► write ────► │file Block │
└─────────────┘                   └─────────────┘                   └───────────┘
```

## WHO WOULD WANT THIS?
The use-case is for scientists or analysts who use Julia and orchestrate data tasks with Prefect. Science and analyst workflows are multi-stage affairs and orchestration is the best solution to managing a proliferation of scheduled jobs. Crucially, the researcher doesn't need or want to set up a production data engineering platform (DBT, Snowflake, Databricks, Azure Data Lake, etc.); this package imagines a very lightweight coder experience. Prefect flows in python are easily understood and quickly deployed (even just locally), and very usable at the individual adhoc level all the way up to large team production environment.

Ultimately, you will desire to deploy some elegant julia process into a production environment, this package can help achieve this via the design considered above.

## DATASET
This is a concrete example of code defined in your Prefect python application that would need a parallel defition in your julia application.
This composite type holds metadata that represents where a data artifact would be written to or read from, and allows a data product to be referenced by a `dataset_name`. The `Dataset` keeps track of file paths and partitions (`rundate`). Other partitions could be implemented, even a Spark/Apache Hive compliant design, if you are a data engineer that likes julia.

Imagine a Prefect flow that reads/writes to locations defined by a python `Dataset` class. When calling a julia process with instructions to read `Dataset(dataset_name="my_cool_dataset")` the prefect flow provides parameters sufficient to construct the `Dataset` instance in the julia process, and the remaining required information is the Prefect server API and names of Prefect blocks required to complete the job. These blocks may define local or remote file systems, details are pulled from the Prefect API endpoint via the `PrefectBlock(blockname::String)` function. The datastore is conceived here as an organized set of files in a Apache hive-ish layout.

```
$HOME/willowdata/projectname/dev/extracts
└── csv
    ├── dataset=my_cool_dataset
    │   ├── rundate=2022-10-23
    │   │   └── data.csv
    │   └── rundate=2022-10-30
    │       └── data.csv
    ├── latest
    │   └── dataset=my_cool_dataset
    │       └── data.csv
```

As a data scientist, it is convenient to reference copious adhoc data artificts by name and let the lightweight orchestration application figure out where to keep it.

## PACKAGE DETAILS
* Interacts with the Prefect Server API to get block information for read/writes, credentials, filesystems, etc.
* The `PrefectBlock(blockname::String)` function requires that a Prefect Server is running, and server endpoint is provided via env variable `PREFECT_API_URL` or a url as keyword argument.
* A good way is to use the `.env` file to specify configuration such as local/remote with a call to `ConfigEnv.dotenv()`
* TODO: A stub Prefect project environment would enable full usage demonstration.

## DEVELOPMENT AND PRODUCTION ENVIRONMENTS
Prefect profiles are good for separating `prod/dev/test` environments, for convenience from the Prefect CLI. Ultimately the API URL defines which Prefect environment you are in. It's useful for these to correspond to git branches. 

The julia environment does not need to be aware of project environment, because it will pull all required information from blocks accessed via each environment's PREFECT_API_URL. For example, in the Prod environment an S3 bucket key "willowdata/prod" would be defined in the `s3-bucket` block. The julia application pulls the s3 bucket and key from block information and otherwise executes in the same way for each environment.

**Managing dev/prod environment with dev/main git branches:** When both main/dev are local, there will be two local prefect DB with different PREFECT_API_URL defined by the Prefect `profiles.toml` profile. The python side of the application will need to distinguish the dev/prod PREFECT_HOME environment variables to define different locations for the prefect DB (which is just a sqlite file). I prefer to do this in a task runner outside of the python application, something like Github Actions, Make, or `just`.

## JUSTFILE
I've found when managing a Prefect orchestrator it is helpful to have a taskrunner program that documents development tasks and executes them for you as well. I use [`just`](https://just.systems/) to launch `dev/main` Prefect DB local servers and manage tasks like Prefect deployment builds ßand running tests before merging and deploying. If you, like most data scientists, like to develop and test on the main branch please ignore this part of the package.

## USAGE
* Examples are usage from the REPL as a guide for Prefect deployment.
* See files in the [`test/`](test/) folder for examples of Block usage and loading data from Prefect DB

### Read a dataframe from a dataset defined by prefect server
*NOTE:* these examples require a local Prefect server to be running, with environment variables defined as in the `.env` file provided in the repo, and a Prefect block previously defined.

```jl
# .env file imported with ConfigEnv.dotent(), or just assignment:
using ConfigEnv; dotenv()
    # or
begin
    ENV["PREFECT_API_URL"] = "http://127.0.0.1:4209/api"
    ENV["PREFECT_LOCAL_DATA_BLOCK"] = "local-file-system/willowdata"
end

using PrefectInterfaces

ds = Dataset(dataset_name="test_data", datastore_type="local");

df = read(ds)
6×7 DataFrame
  Row │ flag   boo    amt      qty    ship     item    day
      │ Int64  Bool   Float64  Int64  Float64  String  Date
 ─────┼───────────────────────────────────────────────────────────
    1 │     0  false    19.0       1     0.5   B001    2021-01-01
    2 │     1   true    11.0       4     0.5   B001    2021-01-01
    3 │     0  false    35.5       1     1.5   B020    2112-12-12
    4 │     1   true    32.5       3     0.55  B020    2020-10-20
    5 │     0  false     5.99     21     0.0   BX00    2021-05-04
    6 │     1   true     5.99    109     1.99  BX00    1984-07-04
```
That's it! The default constructor arguments provide a local filepath to access the previously written Dataset called "test_data".

### Load a FileSystem block from prefect server
```jl
using PrefectInterfaces
ls()
7-element Vector{Any}:
 "aws-credentials/subdivisions"
 "docker-container/lamneth"
 "local-file-system/willowdata"
 "process/red-barchetta"
 "s3-bucket/syrinx"
 "secret/necromancer"
 "slack-webhook/bytor-alert"

fsblock = PrefectBlock("local-file-system/willowdata");

dump(fsblock)
PrefectBlock
  blockname: String "local-file-system/willowdata"
  block: LocalFSBlock
    blockname: String "local-file-system/willowdata"
    blocktype: String "local-file-system"
    basepath: String "/Users/mahiki/willowdata/dev"
    read_path: #4 (function of type PrefectInterfaces.var"#4#5"{String})
      basepath: String "/Users/mahiki/willowdata/dev"
```
The `LocalFSBlock` includes a `read_path()` function, which prepends a base path just as with the Prefect LocalFileSystem block.

### AWSCredentialsBlock
* SecretString type to obfuscate secrets from logs
* Just access the field of ::SecretString type via `.secret` field

```jl
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

# after assigning into S3BucketBlock:
s3 = S3BucketBlock(..etc...)
s3.credentials.aws_secret_access_key.secret
"GUUxx87987xxPXH" # - returns as string
```

# Developers
### Test the Package
When devleping your own fork or via `Pkg.develop()` situation.
```sh
# using justfile
just test

julia --project=. -startup-file=no --eval 'import Pkg; Pkg.test()'
    # BEGIN UNIT TESTS #
    # ================ #

    *NOTE:* Prefect Server must be running (`prefect server start`)

    Test Summary:                          | Pass  Total  Time
    Prefect Block types and function tests |   36     36  6.1s
```

Or, from the REPL
```jl
pkg> activate .
pkg> test
```

### Managing Prefect Environment with Justfile
* Refer to `justfile` for these commands
* `just` task runner would need to be installed, you can achieve the same via bash scripts or many other means.
* These assume your julia project is inside of the Prefect project.

```sh
# examine the env variables injected by just commands
just env

# set the Prefect profile (thus PREFECT_HOME, PREFECT_API_URL) for desired environment.
just use main
just run prefect server start
```
Now your Prefect Server is running locally, this would run in a dedicated terminal or tmux session.
