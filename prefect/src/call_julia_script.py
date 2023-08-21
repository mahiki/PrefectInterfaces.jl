# usage:    just py src/call_julia_script.py
import os
from prefect import flow, get_run_logger
from prefect_shell import ShellOperation
from src.config import PREFECT_API_URL
from src.config import PYTHON_PROJECT_ROOT

julia_path = "julia"        # TODO: put path to julia executable here
julia_project_path = os.path.join(PYTHON_PROJECT_ROOT, "julia")
PREFECT_DATASTORE_DEFAULT_TYPE = "local"
STREAM_LOGS = True if os.getenv("PREFECT_LOGGING_LEVEL")=="DEBUG" else False

@flow(log_prints=True)
def call_julia_script(script_path, prefect_api_url=PREFECT_API_URL):
    """
    This Prefect flow will use the ShellOperation function to execute a shell command invoking a julia script with the usual julia command line:

        julia --startup-file=no --project=../julia --load 'CallinJulia.jl' \
            --eval 'using .CallinJulia; bytor_message(<args>)'
    """
    logger = get_run_logger()
    logger.info(f"Running dataframe report: {script_path}")
    logger.info(f"Calling julia with Prefect API endpoint to: {prefect_api_url}")
    logger.info(f"Julia project abs path DFReport: {julia_project_path}")

    julia_command = f'''{julia_path} --startup-file=no --project={julia_project_path} \
        --load {PYTHON_PROJECT_ROOT}/julia/CallinJulia.jl \
        --eval 'using .CallinJulia; bytor_message("calling from prefect flow."; prefect_api_url="{prefect_api_url}")' '''

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

    logger.info(f"ShellOperation returned\n: {resultblock}")

if __name__ == '__main__':
    call_julia_script(script_path="../julia/CallinJulia.jl", prefect_api_url=PREFECT_API_URL)