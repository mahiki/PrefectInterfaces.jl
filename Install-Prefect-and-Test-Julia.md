# Testing Julia Functions With A Local Prefect Instance
Set up the Python/Prefect environment to test PrefectInterfaces from the REPL.

- [Testing Julia Functions With A Local Prefect Instance](#testing-julia-functions-with-a-local-prefect-instance)
    - [INSTALL PREFECT ENVIRONMENT](#install-prefect-environment)
        - [MacOS Install Dependencies](#macos-install-dependencies)
        - [Initialize Local PrefectDB](#initialize-local-prefectdb)
    - [Julia Commands to Interact with Prefect Server](#julia-commands-to-interact-with-prefect-server)
    - [INSTALL PREFECT (macOS)](#install-prefect-macos)

## INSTALL PREFECT ENVIRONMENT
### MacOS Install Dependencies
*if you don't know about `brew`* [*click here*](https://brew.sh/)

```sh
brew install pipx just python@3
pipx install poetry

git clone https://github.com/mahiki/PrefectInterfaces.jl.git

cd PrefectInterfaces.jl/prefect
poetry install

# open a new terminal to run the prefect server
export PREFECT_HOME=./prefecthome
export PREFECT_SERVER_API_PORT="4300"
poetry run prefect server start

 ___ ___ ___ ___ ___ ___ _____
| _ \ _ \ __| __| __/ __|_   _|
|  _/   / _|| _|| _| (__  | |
|_| |_|_\___|_| |___\___| |_|

Configure Prefect to communicate with the server with:

    prefect config set PREFECT_API_URL=http://127.0.0.1:4300/api

View the API reference documentation at http://127.0.0.1:4300/docs

Check out the dashboard at http://127.0.0.1:4300
# take note of the printed API URL, this is the endpoint to connect from julia.
```
NOTES:
* Now there should be a prefect server running for you to interact with via Julia. The very slick dashboard is accessible via browser at `http://127.0.0.1:4300`.
* Exporting `PREFECT_HOME=./prefecthome` as a relative path means all the `prefect` commands should be run from the `PrefectInterfaces/prefect/` directory.

### Initialize Local PrefectDB
* For the future: the "dev" string points the way toward managing multiple environments
    * Each Prefect DB keeps the name of current env as a string.
* normally I would document and run these with a task runner like `just`
    * `just can also bring .env variables into command enviroment`

```sh
# Now back to your original terminal in the PrefectInterfaces/prefect/ directory:
export PREFECT_API_URL="http://127.0.0.1:4300/api"

# register some blocks
PREFECT_ENV="dev" poetry run prefect block register --file src/blocks/str_prefect_env.py
poetry run prefect block register --file src/blocks/fs_willowdata.py
```
You should now be able to see the registered blocks, and settings in the Dashboard UI:
http://127.0.0.1:4300/blocks
http://127.0.0.1:4300/settings

```sh
# from the command line you can list the blocks and inspect them.
poetry run prefect block ls
13:20:59.049 | DEBUG   | prefect.profiles - Using profile 'dev'
13:20:59.636 | DEBUG   | prefect.client - Connecting to API at http://127.0.0.1:4300/api/
                                                 Blocks
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ ID                                   ┃ Type              ┃ Name       ┃ Slug                         ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ 63b7ebfd-159c-435e-a230-0322eaac9cf9 │ Local File System │ willowdata │ local-file-system/willowdata │
│ 8a0dde20-28cb-404d-875e-08a2e98500fc │ String            │ syrinx     │ string/syrinx                │
└──────────────────────────────────────┴───────────────────┴────────────┴──────────────────────────────┘```

# also, see all the available prefect CLI commands:
poetry run prefect --help
```

## Julia Commands to Interact with Prefect Server
In a terminal:
```sh
export PREFECT_API_URL="http://127.0.0.1:4300/api"

# cd path/to/PrefectInterfaces.jl that was cloned above
julia --project=. --startup-file=no
```

Now the Julia REPL:
```jl
using PrefectInterfaces

# list DB objects, returns a named tuple Vector
obj = ls();

obj.blocks
    # 2-element Vector{String}:
    #  "local-file-system/willowdata"
    #  "string/syrinx"

# now lets try loading the block information from the Prefect server:
env = PrefectBlock("string/syrinx");
dump(env)
    # PrefectBlock
    #   blockname: String "string/syrinx"
    #   block: PrefectInterfaces.StringBlock
    #     blockname: String "string/syrinx"
    #     blocktype: String "string"
    #     value: String "dev"



fsblock = PrefectBlock("local-file-system/willowdata");
dump(fsblock)
    # PrefectBlock
    #   blockname: String "local-file-system/willowdata"
    #   block: LocalFSBlock
    #     blockname: String "local-file-system/willowdata"
    #     blocktype: String "local-file-system"
    #     basepath: String "/Users/mahiki/willowdata/dev"
    #     read_path: #4 (function of type PrefectInterfaces.var"#4#5"{String})
    #       basepath: String "/Users/mahiki/willowdata/dev"
```
You can see the block stores a filepath location, this would be a root folder location used by the `Dataset` type provided in PrefectInterfaces. Note also this path is labelled `dev`, and if you are running another Prefect server instance you would register the 'prod' string with the new PREFECT_API_URL.

Now that the filesystem block is loaded let's load a dataframe from a csv file.

TODO: gotta write the file to local location first.

```jl
ds = Dataset(dataset_name="test_julia_dataset", datastore_type="local")
Dataset
  dataset_name: String "test_julia_dataset"
  datastore_type: String "local"
  dataset_type: String "extracts"
  file_format: String "csv"
  rundate: Dates.Date
  rundate_type: String "latest"
  dataset_path: String "extracts/csv/dataset=test_julia_dataset/rundate=2023-07-26/data.csv"
  latest_path: String "extracts/csv/latest/dataset=test_julia_dataset/data.csv"
  image_path: String "extracts/dataset=test_julia_dataset/rundate=2023-07-26"

ENV["PREFECT_LOCAL_DATA_BLOCK"] = "local-file-system/willowdata"

df = read(ds)
6×7 DataFrame
 Row │ flag   boo    amt      qty    ship     item     day
     │ Int64  Bool   Float64  Int64  Float64  String7  Date
─────┼────────────────────────────────────────────────────────────
   1 │     0  false    19.0       1     0.5   B001     2021-01-01
   2 │     1   true    11.0       4     0.5   B001     2021-01-01
   3 │     0  false    35.5       1     1.5   B020     2112-12-12
   4 │     1   true    32.5       3     0.55  B020     2020-10-20
   5 │     0  false     5.99     21     0.0   BX00     2021-05-04
   6 │     1   true     5.99    109     1.99  BX00     1984-07-04
```

The file was stored at `$HOME/willowdata/dev/extracts/csv/dataset=test_julia_dataset/rundate=2023-07-26/data.csv`.


----------
## INSTALL PREFECT (macOS)
If you don't already have a Prefect Server or Cloud instance running, you'll need to install one locally to test out the Julia **PrefectInterfaces** functionality.

This prefect installation requires:

    pipx    (to install poetry)
    python3
    tmux
    git
    poetry

Commands below are on macOS, should be the same on linux except for `open`.  The dependency installation will be different depending on your linux distribution.

Open a Terminal window:
```sh
brew install pipx just python@3 git tmux
pipx install poetry
cd ~/path/to/desired/repo/location


git clone https://github.com/mahiki/PrefectInterfaces.jl.git PrefectInterfaces
cd PrefectInterfaces/prefect

# This script configures and initializes the local Prefect server.
just init
```

The poetry/prefect environment should be installed now, and a prefect server running in a tmux session. You should be able to interact with it using the `prefect` CLI, remember the environment is managed by Poetry so every Prefect command needs to be prefixed: `poetry run prefect blocks ls`. The `just pre` command inserts `poetry run prefect ` for you.

```sh
tmux ls
#   pi-main: 1 windows

just ls

# examine the contents of the two prefect blocks in the db
just pre block inspect string/syrinx
just pre block inspect local-file-system/willowdata

# open the tmux window, a prefect server and agent are running
just view main

# exit tmux with CTRL-b, d

# The prefect UI should be observable in a browser here
open http://127.0.0.1:4300/blocks

# to close out the prefect server
just kill
```

**Next Steps:** [Julia demo of PrefectInterfaces](julia-demo/Julia-demo.md)