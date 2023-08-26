# Call a Julia Module from Prefect flow
Run a Prefect flow that calls a Julia process. A very simple Julia module is provided in `julia/CallingJulia.jl`, it only prints to stdout and does not have any package dependencies. The `CallingJulia` module and exported function `bytor_message` are an example entrypoint to whatever Julia process you create.

The Prefect python application is a project consisting of this file structure:

    PrefectInterfaces/prefect
        ├── julia
        │   └── CallingJulia.jl
        ├── src
        │   ├── blocks
        │   ├── call_julia_script.py
        │   └── config.py
        └── pyproject.toml



## Usage From Shell
!!! warning "Prefect server available."
    To run this example the local server instance must be installed and running, with the blocks registered. See [Prefect Installation](@ref).

From the `PrefectInterfaces/prefect` directory:

```bash
$ cd ./PrefectInterfaces/prefect

# start the Prefect DB in a backround tmux process
just launch

# run the flow as a python script
just py src/call_julia_script.py
```

Alternately, the same result as above without the **Just** commands

```bash
export PREFECT_HOME="./prefecthome/prefect_main"
export PREFECT_PROFILES_PATH="./profiles.toml"
poetry run prefect server start

PREFECT_API_URL="http://127.0.0.1:4300/api" poetry run python src/call_julia_script.py
```

The Prefect logs will print to stdout, and also view viewable in the Prefect UI from `http://127.0.0.1:4300/flow-runs`.

Logs from Prefect to stdout look like this:
```bash
16:30:12.217 | DEBUG   | prefect.profiles - Using profile 'main'
cwd: /Users/mahiki/repo/julia-pkgs/PrefectInterfaces/prefect
16:30:12.614 | DEBUG   | prefect.client - Connecting to API at http://127.0.0.1:4300/api/
16:30:12.639 | INFO    | prefect.engine - Created flow run 'belligerent-markhor' for flow 'call-julia-script'
16:30:12.639 | INFO    | Flow run 'belligerent-markhor' - View at http://127.0.0.1:4300/flow-runs/flow-run/d8c7db9d-de9e-4d08-b115-dc24ef90685e
16:30:12.640 | DEBUG   | prefect.task_runner.concurrent - Starting task runner...
16:30:12.648 | DEBUG   | prefect.client - Connecting to API at http://127.0.0.1:4300/api/
16:30:12.724 | DEBUG   | Flow run 'belligerent-markhor' - Executing flow 'call-julia-script' for flow run 'belligerent-markhor'...
16:30:12.724 | DEBUG   | Flow run 'belligerent-markhor' - Beginning execution...
16:30:12.724 | INFO    | Flow run 'belligerent-markhor' - Calling module from module_path: julia/CallingJulia.jl
# ...etc...
16:30:13.164 | INFO    | Flow run 'belligerent-markhor' - ShellOperation returned:
Hello from the Julia script, prints are logged from prefect flow.

┌ Info: By-Tor left a message
└   input = "calling from prefect flow."
┌ Info: You can using PrefectInterfaces commands to retrieve blocks because
└   prefect_api_url = "http://127.0.0.1:4300/api"
16:30:13.209 | DEBUG   | prefect.task_runner.concurrent - Shutting down task runner...
16:30:13.209 | INFO    | Flow run 'belligerent-markhor' - Finished in state Completed()
```


!!! note "Helpful Hints"
    Debugging errors can be be tricky because of the stacktraces only partially get sent back from Julia.
    Things to watch for:
    * Be sure of the process working directory and relative paths to Module/assets.
    * Loading from the julia project path, no quotes: ` --load ./CallingJulia.jl `
    * Julia project needs package dependencies installed in the usual way (ie Project.toml). 
    * Instantiating the julia project in the execution environment, ie `Pkg.instantiate()`

    Example:
    ```py
    # the main module call from call_julia_script.py is from python project root:
    call_julia_script(module_path="julia/CallingJulia.jl", prefect_api_url=PREFECT_API_URL)
    ```
