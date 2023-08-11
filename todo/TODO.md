# TODO
TODO: tests all broken after v0.2.0 refactor
TODO: write_path/read_path shouldnt only support dataframes, allow to specify sink type
TODO: read/write remote s3 bucket
TODO: docs are out of sync. README very basic, install and test in julia clean up.
TODO: init() command to execute dotenv()? that gets those env into environment, not 'using'...
    * create a Config type to hold the dotenv() dict for keys with "PREFECT_*" prefix. 
    * see dataset.jl



DONE: PrefectBlock.write_path, write(Dataset)
DONE: make a toy prefect instance, prefect poetry project directory to start a local server
DONE: justfile is janky, mostly not used. prob after testing setup. FIXED, usable.

----------
## DONE: PROBLEM: PREFECT_API_URL
How does the julia process know which API to call?  I have been managing that with the PREFECT_ENVIRONMENT env variable.

* Julia process is called via process and parameters from prefect, must pass in main/dev or better the PREFECT_API_URL.
* settings.PREFECT_API_URL.value()
* no need to access or reference the active git branch or environment name.
* The julia process requires a running server to access blocks
* Dataset fields can be overridden in development to read/write locally

```py
# in Prefect application
from prefect import settings
x = settings.PREFECT_API_URL.value()
'http://127.0.0.1:4209/api'
```
So it works. The julia application needs to receive this value as a parameter.
