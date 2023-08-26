# Prefect Installation
This local install environment is managed by [Poetry](https://python-poetry.org/), ensuring isolation from other python environments.
These are the instructions to install a local Prefect instance for package testing, demonstration, or even as a lightweight local workflow orchestration tool. [Prefect](https://docs.prefect.io) provides a command-line interface and python SDK.

This [`prefect/` folder](https://github.com/mahiki/PrefectInterfaces.jl/tree/main/prefect) holds all the configuration for installing a small Prefect DB (which is a sqlite file stored in the PREFECT_HOME directory).

## Justfile
We use [justfile](https://just.systems/). It is convenient to manage development tasks like starting/stopping the server with a task runner of some sort. The just commands inject the necessary environment variables (from `.env`) and provides a self-documenting scripting tool.

Find paralled installation instructions that eschew `just` in [Install Prefect Environment - Poetry Commands](@ref).

## Install Prefect (Macos)
If you don't already have a Prefect Server or Cloud instance running, you'll need to install one locally to test out the Julia **PrefectInterfaces** functionality.

!!! note "Prefect Install Dependencies
    * pipx, to install poetry
    * python3
    * tmux
    * git
    * poetry

Commands below are on macOS, should be the same on linux except for `open`.  The dependency installation will be different depending on your linux distribution.

Open a Terminal window:
```sh
$ brew install pipx just python@3 git tmux

pipx install poetry

git clone https://github.com/mahiki/PrefectInterfaces.jl PrefectInterfaces

cd PrefectInterfaces/prefect

# This script configures and initializes the local Prefect server.
just init
```

The poetry/prefect environment should be installed now, and a prefect server running in a tmux session. You should be able to interact with it using the `prefect` CLI, the python API, or the Julia commands in the [Julia Demo on REPL](@ref) section.  Remember the environment is managed by Poetry so every CLI Prefect command needs to be prefixed: `poetry run prefect blocks ls`. The `just pre` command inserts `poetry run prefect ` for you, and all `just` commands also inject the very important `PREFECT_PROFILES_PATH` and other env variables.

```sh
$ tmux ls
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
#                                    string/syrinx
# ┌───────────────────────────────────────────┬──────────────────────────────────────┐
# │ Block Type                                │ String                               │
# │ Block id                                  │ a3de68af-c74b-40e5-9213-716b1b051dd1 │
# ├───────────────────────────────────────────┼──────────────────────────────────────┤
# │ value                                     │ main                                 │
# └───────────────────────────────────────────┴──────────────────────────────────────┘

just pre block inspect local-file-system/willowdata

# open the tmux window, a prefect server and agent are running
just view main

# exit tmux with CTRL-b, d

# examine the env variables injected by just commands
just env

# set the Prefect profile (thus PREFECT_HOME, PREFECT_API_URL) for desired environment.
just use main

# to close out the prefect server
just kill
```

!!! note "Dashboard Local URL"
    A nice dashboard should be available locally on a browser here: http://127.0.0.1:4300


----------
**Next Steps:** [Julia Demo on REPL](@ref)
