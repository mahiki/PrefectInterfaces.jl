# PREFECT_API_URL is needed to call the Prefect server and get Block information.
using ConfigEnv

dotenv("src/.env", ".env"; overwrite = false)
# TODO: this doesn't make any sense. dotenv call needs to happen during the new julia session after `using PrefectInterfaces`. putting `dotenv` in the package just happends when compiling, but not shared the the julia environment on REPL. maybe? during runtests.jl I was getting ENV vars from this...
#   prob something like init_from_dotenv() that grabs ENV variables for current prefect config.
#   TODO: akshually, dotenv should be for tests only, package user deals with this.

"""
    PrefectAPI(url::String) <:AbstractPrefectInterface

Mutable struct tha stores the Prefect server api endpoint. All `PrefectInterface` operations depend on connecting to a running Prefect server to pull block information. Constructor with no arguments assigns env variable `PREFECT_API_URL` to url field.

# Examples:
```jldoctest
julia> ENV["PREFECT_API_URL"] = "http://127.0.0.1:4200/api";

julia> api = PrefectAPI()
PrefectAPI("http://127.0.0.1:4200/api")

julia> api.url
"http://127.0.0.1:4200/api"

julia> api.url = "http://127.0.0.1:4333/api"
"http://127.0.0.1:4333/api"

julia> PrefectAPI("http://127.0.0.1:4444/api").url
"http://127.0.0.1:4444/api"
```
"""
mutable struct PrefectAPI <: AbstractPrefectInterface
    url::AbstractString
end
PrefectAPI() = begin
    if haskey(ENV, "PREFECT_API_URL")
        PrefectAPI(ENV["PREFECT_API_URL"])
    else
        @warn "Prefect API URL is needed to call Prefect Server.\n" *
            "Set ENV variable PREFECT_API_URL or provide endpoint URL to this constructor."
        throw(KeyError("PREFECT_API_URL"))
    end
end

mutable struct PrefectDatastoreType <: AbstractPrefectInterface
    remote::AbstractString
    var"local"::AbstractString
end
PrefectDatastoreType() = begin
    if ! (haskey(ENV, "PREFECT_DATA_BLOCK_REMOTE") && haskey(ENV, "PREFECT_DATA_BLOCK_LOCAL"))

        @warn "Env variables needed for default constructor:\n" *
            "PREFECT_DATA_BLOCK_REMOTE\n" *
            "PREFECT_DATA_BLOCK_LOCAL"
        throw(KeyError("PREFECT_DATA_BLOCK_REMOTE and/or PREFECT_DATA_BLOCK_LOCAL"))
    else
        PrefectDatastoreType(ENV["PREFECT_DATA_BLOCK_REMOTE"], ENV["PREFECT_DATA_BLOCK_LOCAL"])
    end
end


# TODO: so far not used anywhere. idea is a type to load env with dotenv when contstructor is called.
struct PrefectConfig <: AbstractPrefectInterface
    env::Dict
end