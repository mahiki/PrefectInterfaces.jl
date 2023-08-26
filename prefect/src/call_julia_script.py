# usage:    just py src/call_julia_script.py
# note:     the Prefect server needs to be accessible at PREFECT_API_URL
import os
from prefect import flow, get_run_logger
from prefect_shell import ShellOperation
from src.config import PREFECT_API_URL
from src.config import PYTHON_PROJECT_ROOT

julia_path = "julia"    # may need explicit julia path here
julia_project_path = os.path.join(PYTHON_PROJECT_ROOT, "julia")
PREFECT_DATASTORE_DEFAULT_TYPE = "local"
STREAM_LOGS = True

@flow(log_prints=True)
def call_julia_script(module_path, prefect_api_url=PREFECT_API_URL):
    """
    This Prefect flow will use the ShellOperation function to execute a shell command invoking a julia script with the usual julia command line:

        julia --startup-file=no --project=./julia --load 'CallingJulia.jl' \
            --eval 'using .CallingJulia; bytor_message(<args>)'
    """
    logger = get_run_logger()
    logger.info(f"Calling module from module_path: {module_path}")
    logger.info(f"Calling julia with Prefect API endpoint to: {prefect_api_url}")
    logger.info(f"Julia project abs path DFReport: {julia_project_path}")
    logger.debug(f"Dumping some vars, STREAM_LOGS: {STREAM_LOGS}" )

    julia_command = f'''julia --startup-file=no --project=julia \
        --load '{module_path}' \
        --eval 'using .CallingJulia; bytor_message(input="calling from prefect flow.", prefect_api_url="{prefect_api_url}")' '''

    logger.info(f"julia command to shell:\n{julia_command}")
    logger.info(f"CWD: {os.getcwd()}")

    result = ShellOperation(
        stream_output=STREAM_LOGS
        , commands=[
            julia_command
        ]
        , working_dir="."
        , env={
            "JULIA_PATH": julia_path
            , "PREFECT_DATASTORE_DEFAULT_TYPE": PREFECT_DATASTORE_DEFAULT_TYPE
            }
        ).run()
    
    resultblock = "\n".join(result)

    logger.info(f"ShellOperation returned:\n{resultblock}")

if __name__ == '__main__':
    call_julia_script(module_path="julia/CallingJulia.jl")