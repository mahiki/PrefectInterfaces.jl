module Datasets

using Dates, CSV, DataFrames
using Parameters
using PrefectInterfaces
import Base: read, write

export Dataset, read, write
include("config.jl")

"""
    Dataset(dataset_name=str::String; kwargs...)

An object that stores configuration, and file path locations. Assertions constrain valid field values. If `rundate` is not the current date, the `latest_path` will not be used.

*NOTE:* No positional arguments allowed b/c of @kw_def, keyworded args only.

Supported keyword arguments (default show first):

    dataset_name::String (required)
    datastore_type ∈ ["local", "remote"]
    dataset_type ∈ ["extracts", "reports", "images"]
    file_format ∈ ["csv"]
    rundate::Date = Datest.today()
    rundate_type ∈ ["latest", "specific"]

Read/write behavior depends on rundate/rundate_type combination as follows:

    rundate_type|  rundate   || read    |  write
    ------------|------------||---------|-----------------------------------------
    latest      |  == today  || latest  |  [latest, rundate]   default option
    latest      |  != today  || latest  |  [latest]            dont write to date partition (rare)
    specific    |  == today  || rundate |  [rundate]
    specific    |  != today  || rundate |  [rundate]

# Examples
```julia
julia> begin
    ENV["PREFECT_DATA_BLOCK_LOCAL"] = "local-file-system/willowdata"
    ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api"
end;

julia> ds = Dataset(dataset_name="test_table", datastore_type="local")
Dataset
  dataset_name: String "test_table"
  datastore_type: String "local"
  dataset_type: String "extracts"
  file_format: String "csv"
  rundate: Dates.Date
  rundate_type: String "latest"
  dataset_path: String "extracts/csv/dataset=test_table/rundate=2023-07-24/data.csv"
  latest_path: String "extracts/csv/latest/dataset=test_table/data.csv"
  image_path: String "extracts/dataset=test_table/rundate=2023-07-24"

julia> df = read(ds)
1×2 DataFrame
 Row │ column1                            result
     │ String                             String7
─────┼────────────────────────────────────────────
   1 │ If you can select this table you…  PASSED
```
"""
@with_kw struct Dataset <: AbstractPrefectInterface
    dataset_name::String
    datastore_type::String = PrefectDatastoreNames().default
    dataset_type::String = "extracts"
    file_format::String = "csv"
    rundate::Date = Dates.today()
    rundate_type::String = rundate != Dates.today() ? "specific" : "latest"
    dataset_path::String = "$dataset_type/$file_format/dataset=$dataset_name/rundate=$rundate/data.csv"
    latest_path::String = "$dataset_type/$file_format/latest/dataset=$dataset_name/data.csv"
    image_path::String = begin
        @warn "image paths not supported yet"
        "$dataset_type/dataset=$dataset_name/rundate=$rundate"
    end
    @assert dataset_type ∈ ["extracts", "reports", "images"]
    @assert datastore_type ∈ ["local", "remote"]
    @assert rundate_type ∈ ["latest", "specific"]
    @assert file_format ∈ ["csv"]
    # TODO: image path and filename doesnt quite make sense as seperate field. also, this is ugly looking. maybe ../image.xxx, suffix must carry through
end


"""
    read(ds::Dataset)

Returns a `DataFrame` by calling `CSV.read` on a filepath defined by the Dataset type.

*NOTE:* A prefect server must be available to use Dataset read function.

# Examples
```julia
julia> begin
    ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api"
    ENV["PREFECT_DATA_BLOCK_LOCAL"] = "local-file-system/willowdata"
end;

julia> df = read(Dataset(dataset_name="test_table", datastore_type="local"))
1×2 DataFrame
 Row │ column1                            result
     │ String                             String7
─────┼────────────────────────────────────────────
   1 │ If you can select this table you…  PASSED
```
"""
function read(
    ds::Dataset
    ; block::AbstractPrefectBlock = block_selector(ds)
    )
    prefect_block = block
    path_key = rundate_path_selector(ds).read
    prefect_block.block.read_path(path_key)
end

"""
    write(ds::Dataset, df::DataFrame)

Writes a `DataFrame` via `CSV.write` to a filepath defined by the `Dataset` type.

*NOTE:* A prefect server must be available to use Dataset read function.
"""
function write(
    ds::Dataset
    , df::AbstractDataFrame
    ; block::AbstractPrefectBlock = block_selector(ds)
    )
    prefect_block = block
    path_key = rundate_path_selector(ds).write
    [prefect_block.block.write_path(x, df) for x in path_key]
end


"""
    block_selector(ds::Dataset)

Returns the PrefectBlock corresponding to the remote or local datastore type. This block will be used in read/write of dataset paths.
"""
function block_selector(ds::Dataset)
    datablocks = PrefectDatastoreNames()
    return PrefectBlock(getproperty(datablocks, Symbol(ds.datastore_type)))
end


function rundate_path_selector(ds::Dataset)
    if ds.rundate_type == "latest"
        if ds.rundate == Dates.today()
            return (read=ds.latest_path, write=[ds.latest_path, ds.dataset_path])
        else
            return (read=ds.latest_path, write=[ds.latest_path])
        end
    else
        return (read=ds.dataset_path, write=[ds.dataset_path])
    end
end


# latest and specific read/write paths - "latest" is convenient to point to
# if explicitly "latest" then thats what you should get.
#=
    rundate_type  rundate       read     write
    ------------|------------|---------|-----------------------------------------
    latest        == today   |  latest   [latest, rundate]   default option
    latest        != today   |  latest   [latest]            dont write to date partition (rare)
    specific      == today   |  rundate  [rundate]
    specific      != today   |  rundate  [rundate]
=#

end # Dataset