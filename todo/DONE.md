# DONE
>2023-08-21: [Managing TODOs with issues on the repo](https://github.com/mahiki/PrefectInterfaces.jl/issues)

----------
DONE: split Dataset into new sub module. Not the same.
DONE: dataset tests, more detail on split paths. file exist on expected paths
DONE: redo all tests, can initialize prefect or just create blocks by constructor.
DONE: PrefectBlock.write_path, write(Dataset)
DONE: make a toy prefect instance, prefect poetry project directory to start a local server
DONE: justfile is janky, mostly not used. prob after testing setup. FIXED, usable.
DONE: ds.rundate_type basically ignored if not current date.
    * but if you want to read the latest dataset, your today rundate isnt what the actual rundate was
    * a mental mismatch could prob ignore, but if you explicitly "latest" then thats what you should get.
NODO: init() command to execute dotenv()? that gets those env into environment, not 'using'...
    * create a Config type to hold the dotenv() dict for keys with "PREFECT_*" prefix. 
    * see dataset.jl
    * **actually dotenv is a test dependency**, and env mgmt is for the user application
DONE: Docs cleanup. README should very basic, install and test in julia clean up.
    * DONE: [julia-demo](../julia-demo/Julia-demo.md)
    * DONE: README.md, prefect/README.md
    * DONE: [non-just setup](../prefect/setup-without-justfile.md)

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
'http://127.0.0.1:4300/api'
```
So it works. The julia application needs to receive this value as a parameter.

## DONE: SECRETBLOCK OBFUSCATE DUMP
Issue #9

DONE: override dump to obscure SecretBlock from logs
```jl
sblk = SecretBlock("poo", "patype", "abc123")
SecretBlock("poo", "patype", ####Secret####)

show(sblk)
SecretBlock("poo", "patype", ####Secret####)
dump(sblk)
SecretBlock
  blockname: String "poo"
  blocktype: String "patype"
  value: SecretString
    secret: String "abc123"

Base.dump(io::IOContext, s::SecretString, n::Int64, indent) = print(io, "SecretString")
dump(sblk)
# SecretBlock
#   blockname: String "poo"
#   blocktype: String "patype"
#   value: SecretString
dump(sblk, maxdepth = 4)
# SecretBlock
#   blockname: String "poo"
#   blocktype: String "patype"
#   value: SecretString
```
DONE
