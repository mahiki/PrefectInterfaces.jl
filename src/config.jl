"""
    PrefectAPI(url::String, key::SecretString) <:AbstractPrefectInterface

Mutable struct tha stores the Prefect server api endpoint. All `PrefectInterface` operations depend on connecting to a running Prefect server to pull block information. Constructor with no arguments assigns env variables `PREFECT_API_URL`, `PREFECT_API_KEY`
    
If `PREFECT_API_KEY` does not exist then an empty string is assigned to `key`. For Prefect Server with no authentication (or with auth managed by connection string) the empty key will not interfere with API calls.

# Examples:
```jldoctest
julia> using PrefectInterfaces

julia> ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api";

julia> api = PrefectAPI()
PrefectAPI("http://127.0.0.1:4300/api", ####Secret####)

julia> api.url
"http://127.0.0.1:4300/api"

julia> api.key.secret
""

julia> api.url = "https://api.prefect.cloud/api/accounts/0eEXAMPLE";

julia> api.key = SecretString("abcd1234")
####Secret####

julia> api = PrefectAPI("https://api.prefect.cloud/api/accounts/0eEXAMPLE", "abcd1234")
PrefectAPI("https://api.prefect.cloud/api/accounts/0eEXAMPLE", ####Secret####)
```
"""
mutable struct PrefectAPI <: AbstractPrefectConfig
    url::AbstractString
    key::SecretString
    PrefectAPI(url, key) = new(url, SecretString(key))
end
PrefectAPI(url) = PrefectAPI(url, "")
PrefectAPI() = begin
    if ! haskey(ENV, "PREFECT_API_URL")
        @warn "Prefect API URL is needed to call Prefect Server.\n" *
        "Zero-argument constructor requires ENV value PREFECT_API_URL optional PREFECT_API_KEY."
    end
    if ! haskey(ENV, "PREFECT_API_KEY")
        PrefectAPI(ENV["PREFECT_API_URL"])
    else
        PrefectAPI(ENV["PREFECT_API_URL"], ENV["PREFECT_API_KEY"])
    end
end


# TODO: so far not used anywhere. idea is a type to load env with dotenv when contstructor is called.
# maybe PrefectConfig is a global struct to hold config and is accessible without passing in and 
#   out of a bunch of function calls. simply the model and changes get easier.
#   it makes it more sensible when handing off from python shell call to an included file
#   you cant pass parameters to an included file but you want access to parameters passed from 
#   prefect flows.
#   Every PrefectInterfaces session has a PrefectConfig.init() action or some initialization.
struct PrefectConfig <: AbstractPrefectConfig
    env::Dict
end
