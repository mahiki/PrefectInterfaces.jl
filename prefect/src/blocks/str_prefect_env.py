#   This block is added to each prefect DB instance to disambiguate prod/dev paths, etc.
#   usage:
#       PREFECT_ENV="main" poetry run prefect block register --file src/blocks/str_prefect_env.py

import os
from prefect.blocks.system import String
PREFECT_ENV = os.environ["PREFECT_ENV"]

string_block = String(value=PREFECT_ENV)
string_block.save(name="syrinx", overwrite=True)
