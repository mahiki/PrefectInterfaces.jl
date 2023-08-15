"""
    PrefectDatastoreNames(remote::String, local::String) <: AbstractPrefectInterface
A struct to store the names of Prefect blocks which reference local and remote file storage.
The default constructor pulls the names from ENV variables

    PREFECT_DATA_BLOCK_REMOTE
    PREFECT_DATA_BLOCK_LOCAL
"""
mutable struct PrefectDatastoreNames <: AbstractPrefectInterface
    remote::AbstractString
    var"local"::AbstractString
end
PrefectDatastoreNames() = begin
    if ! (haskey(ENV, "PREFECT_DATA_BLOCK_REMOTE") && haskey(ENV, "PREFECT_DATA_BLOCK_LOCAL"))

        @warn "Env variables needed for default constructor:\n" *
            "PREFECT_DATA_BLOCK_REMOTE\n" *
            "PREFECT_DATA_BLOCK_LOCAL"
        throw(KeyError("PREFECT_DATA_BLOCK_REMOTE and/or PREFECT_DATA_BLOCK_LOCAL"))
    else
        PrefectDatastoreNames(ENV["PREFECT_DATA_BLOCK_REMOTE"], ENV["PREFECT_DATA_BLOCK_LOCAL"])
    end
end
