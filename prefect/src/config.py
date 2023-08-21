import os
from os.path import dirname
from dotenv import load_dotenv

print(f"cwd: {os.getcwd()}")
PYTHON_PROJECT_ROOT = dirname(dirname(os.path.abspath(__file__)))

load_dotenv(dotenv_path="../.env", override=False)

PREFECT_API_URL                 = os.getenv("PREFECT_API_URL")

PREFECT_DATA_BLOCK_REMOTE       = os.getenv("PREFECT_DATA_BLOCK_REMOTE")
PREFECT_DATA_BLOCK_LOCAL        = os.getenv("PREFECT_DATA_BLOCK_LOCAL")
PREFECT_ENV_BLOCK               = os.getenv("PREFECT_ENV_BLOCK")

PREFECT_DATASTORE_DEFAULT_TYPE  = os.getenv("PREFECT_DATASTORE_DEFAULT_TYPE")
PREFECT_LOCAL_DATA_DIRNAME      = os.getenv("PREFECT_LOCAL_DATA_DIRNAME")
PREFECT_LOCAL_DEPLOY_DIRNAME    = os.getenv("PREFECT_LOCAL_DEPLOY_DIRNAME")
