# Install Prefect Environment, Poetry Commands
This is the same as the [Install section of prefect](README.md#install-prefect-macos), without using the `justfile` taskrunner. It makes the relationship between env variables and Prefect DB location and API more explicit.

```sh
brew install pipx just python@3
pipx install poetry

git clone https://github.com/mahiki/PrefectInterfaces.jl.git PrefectInterfaces

cd PrefectInterfaces/prefect

poetry env use 3.11
poetry install

# open a new terminal to run the prefect server
export PREFECT_HOME=./prefecthome
export PREFECT_SERVER_API_PORT="4300"
export PREFECT_PROFILES_PATH="./profiles.toml"
poetry run prefect server start
```

Notice a nice dashboard should be available locally on a browser here: http://127.0.0.1:4300

Now initialize the Prefect environment by registering some Blocks. We can establish a "main" and "dev" environment by starting another prefect server at a different `PREFECT_SERVER_API_PORT` and `PREFECT_HOME`.

Back to the first terminal session in `PrefectInterfaces/prefect` folder.

```sh
export PREFECT_HOME=./prefecthome
export PREFECT_API_URL="http://127.0.0.1:4300/api"
export PREFECT_PROFILES_PATH="./profiles.toml"

# register some blocks
PREFECT_ENV="main" poetry run prefect block register --file src/blocks/str_prefect_env.py
poetry run prefect block register --file src/blocks/fs_willowdata.py
poetry run prefect block register --file src/blocks/secret_necromancer.py
```

You should now be able to see the registered blocks, and settings in the Dashboard UI:
http://127.0.0.1:4300/blocks
http://127.0.0.1:4300/settings

```sh
# from the command line you can list the blocks and inspect them.
poetry run prefect block ls
13:20:59.049 | DEBUG   | prefect.profiles - Using profile 'main'
13:20:59.636 | DEBUG   | prefect.client - Connecting to API at http://127.0.0.1:4300/api/
                                                 Blocks
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ ID                                   ┃ Type              ┃ Name        ┃ Slug                         ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ 39c985b0-149c-4b66-886f-6d2fb773ff49 │ Local File System │ willowdata  │ local-file-system/willowdata │
│ db021ae5-826b-4fe6-8ac4-9ece159658bf │ Secret            │ necromancer │ secret/necromancer           │
│ 41636ef0-8e76-4f85-b3b7-cbcec0518faf │ String            │ syrinx      │ string/syrinx                │
└──────────────────────────────────────┴───────────────────┴─────────────┴──────────────────────────────┘
                             List Block Types using `prefect block type ls`

poetry run prefect profiles inspect main
    # PREFECT_LOGGING_LEVEL='INFO'
    # PREFECT_SERVER_API_PORT='4300'
    # PREFECT_API_URL='http://127.0.0.1:4300/api'

# also, see all the available prefect CLI commands:
poetry run prefect --help
```
