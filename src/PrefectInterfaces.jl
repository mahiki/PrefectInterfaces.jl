"""
PrefectInterfaces.jl provides composite types to enable:

* Interactive REPL connections to a Prefect server.
* Prefect deployed julia processes that can be called from the python API with parameters.

Use of this package requires a running Prefect server to make connections to the Prefect server REST API, configured with the environment variable `PREFECT_API_URL` or by specifying the endpoint url in constructor calls. Calling `PrefectBlock(blockname::String)` retrieves Prefect block information by name, and thus julia modules can be built to connect to resources defined by those blocks.

# Examples
```jldoctest
julia> using PrefectInterfaces
julia> ENV["PREFECT_API_URL"] = "http://127.0.0.1:4209/api";

julia> ls()
5-element Vector{Any}:
 "aws-credentials/subdivisions"
 "docker-container/lamneth"
 "local-file-system/willowdata"
 "process/red-barchetta"
 "string/syrinx"

julia> dump(PrefectBlock("local-file-system/willowdata"))
PrefectBlock
  blockname: String "local-file-system/willowdata"
  block: LocalFSBlock
    blockname: String "local-file-system/willowdata"
    blocktype: String "local-file-system"
    basepath: String "/Users/mahiki/willowdata/dev"
    read_path: #4 (function of type PrefectInterfaces.var"#4#5"{String})
      basepath: String "/Users/mahiki/willowdata/dev"
```
"""
module PrefectInterfaces

abstract type AbstractPrefectInterface end
abstract type AbstractPrefectBlock <: AbstractPrefectInterface end

import Base: read, write

export  PrefectAPI,
        PrefectBlock,
        AWSCredentialsBlock,
        LocalFSBlock,
        S3BucketBlock,
        StringBlock,
        SecretString,
        CredentialPairBlock,
        Dataset,
        ls,
        getblock,
        makeblock,
        read,
        write


include("config.jl")
include("prefectblock/prefectblock.jl")
include("prefectblock/prefectblocktypes.jl")
include("dataset/dataset.jl")










end # PrefectInterfaces