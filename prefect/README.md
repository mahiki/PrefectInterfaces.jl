# Prefect Installation, Environment Managed by Poetry
These are the instructions to install a local Prefect instance for package testing and demonstration. The local python environment here is managed by [poetry](https://python-poetry.org/). Prefect provides a command-line interface and python SDK.

This `./prefect` folder holds all the configuration for installing a small Prefect DB (which is a sqlite file stored in the PREFECT_HOME directory).

This lightweight installation will enable testing of the PrefectInterfaces functions and demonstrates managing an orchestration environment that can implement julia code.

## JUSTFILE
We use [justfile](https://just.systems/). It is convenient to manage development tasks like starting/stopping the server with a task runner of some sort. The just commands inject the necessary environment variables (from `.env`) and provides a self-documenting scripting tool.

There are some non-`just` [example commands in this file.](setup-without-justfile.md)
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

The poetry/prefect environment should be installed now, and a prefect server running in a tmux session. You should be able to interact with it using the `prefect` CLI, remember the environment is managed by Poetry so every Prefect command needs to be prefixed: `poetry run prefect blocks ls`. The `just pre` command inserts `poetry run prefect ` for you, and all `just` commands also inject the very important `PREFECT_PROFILES_PATH` and other env variables.

```sh
tmux ls
#   pi-main: 1 windows

just ls
#                                                  Blocks
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ ID                                   ┃ Type              ┃ Name        ┃ Slug                         ┃
# ┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
# │ 39c985b0-149c-4b66-886f-6d2fb773ff49 │ Local File System │ willowdata  │ local-file-system/willowdata │
# │ db021ae5-826b-4fe6-8ac4-9ece159658bf │ Secret            │ necromancer │ secret/necromancer           │
# │ 41636ef0-8e76-4f85-b3b7-cbcec0518faf │ String            │ syrinx      │ string/syrinx                │
# └──────────────────────────────────────┴───────────────────┴─────────────┴──────────────────────────────┘


# examine the contents of the two prefect blocks in the db
just pre block inspect string/syrinx
just pre block inspect local-file-system/willowdata

# open the tmux window, a prefect server and agent are running
just view main

# exit tmux with CTRL-b, d

# The prefect UI should be observable in a browser here
open http://127.0.0.1:4300/blocks

# examine the env variables injected by just commands
just env

# set the Prefect profile (thus PREFECT_HOME, PREFECT_API_URL) for desired environment.
just use main

# to close out the prefect server
just kill
```

**Next Steps:** [Julia demo of PrefectInterfaces](../julia-demo/Julia-demo.md)

----------
## DEVELOP / TEST
```sh
julia --project=. --startup-file=no --eval 'import Pkg; Pkg.test()'
# SERVER HEALTH CHECK #
# =================== #
[ Info: Prefect Server must be running (`prefect server start`)
Active Prefect Environment: main
Calling http://127.0.0.1:4300/api/health
Server reponse status: 200 OK

# BEGIN UNIT TESTS #
# ================ #

Test Summary:                 | Pass  Total  Time
All tests                     |   86     86  2.5s
  Config                      |    9      9  0.4s
  Block types, function tests |   58     58  1.8s
  Dataset function            |   19     19  0.3s

     Testing PrefectInterfaces tests passed
```

Alternately, using the `justfile`
```sh
cd .../PrefectInterfaces

just test
```

Or, from the REPL:

`julia --project=.`
```jl
pkg> activate .
pkg> test
```
