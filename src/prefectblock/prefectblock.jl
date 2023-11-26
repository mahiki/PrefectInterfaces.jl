using HTTP, JSON
using Parameters, Match

"""
    PrefectBlock <: AbstractPrefectBlock

Constructors:

    PrefectBlock(blockname::String)
    PrefectBlock(blockname::String, api_url::String)
    PrefectBlock(blockname::String, block::AbstractPrefectBlock)

Returns a Prefect Block from the Prefect server, the block data is stored in the `block` field. Prefect Block names are strings called 'slugs', formatted as `block-type-name/block-name`.
A Prefect Block is uniquely specified by its name and the Prefect DB where it is stored, therefore the API URL is necessary for the constructor.

A non-server block can be constructed by supplying an AbstractPrefectBlock object.

The AbstractPrefectBlock types are meant to mirror the functionality defined in the Prefect Python API, for example `LocalFSBlock` has a `write_path()` method attached which only writes to paths relative from the block basepath.

# Examples:
```jldoctest
julia> using PrefectInterfaces

julia> spec_fsblock = LocalFSBlock("local-file-system/xanadu", "local-file-system", "/usr/mahiki/xanadu/dev");

julia> fsblock = PrefectBlock("local-file-system/xanadu", spec_fsblock);

julia> fsblock.blockname
"local-file-system/xanadu"

julia> propertynames(fsblock.block)
(:blockname, :blocktype, :basepath, :read_path, :write_path)

julia> fsblock.block.basepath
"/usr/mahiki/xanadu/dev"
```
"""
struct PrefectBlock <: AbstractPrefectBlock
    blockname::String
    block::AbstractPrefectBlock
end
PrefectBlock(blockname::String) = begin
    url = PrefectAPI().url
    blockdict = getblock(blockname, api_url=url)
    newblock = makeblock(blockdict)
    @assert blockname == newblock.blockname
    PrefectBlock(blockname, newblock)
end
PrefectBlock(blockname::String, api_url::String) = begin
    url = PrefectAPI(api_url).url
    block_dict = getblock(blockname, api_url=url)
    newblock = makeblock(block_dict)
    @assert blockname == newblock.blockname
    PrefectBlock(blockname, newblock)
end

"""
    ls(; type="block", api_url::String=PrefectAPI().url)

Calls the Prefect server and returns a list of all defined blocks as Vector{String}. Default is to list all blocks, later implementation could include "flows", "deployments", "work-pool" etc.

# Examples:
```julia
julia> ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api";

julia> ls()
11-element Vector{Any}:
 "aws-credentials/subdivisions"
 "docker-container/lamneth"
 "github/dev"
 "github/main"
 "local-file-system/willowdata"
 "process/red-barchetta"
 "s3/necromancer"
 "s3-bucket/willowdata"
 "secret/necromancer"
 "slack-webhook/bytor-alert"
 "string/environment"
```
"""
function ls(; type="block", api_url::String=PrefectAPI().url)
    # TODO: this could be better, have a show definition and return PrefectBlockList, as a dict of julia block type or block id.
    # TODO: deployments, flows, flow-run, etc.
    if type ∉ ["block"]
        @warn """Only type="block" currently supported""" type
        return nothing
    end
    response = try
        HTTP.request(
            "POST"
            , "$(api_url)/block_documents/filter"
            , connect_timeout = 3
            , readtimeout = 5
            , retries = 1
            )
    catch ex
        if typeof(ex) ∈ [HTTP.Exceptions.StatusError, HTTP.ConnectError]
            @warn "no connection." api_url
            println("$ex")
            return nothing
        else
            rethrow()
        end
    end
    blockdata = JSON.parse(String(response.body))
    blocklist = String[]
    for i in keys(blockdata)
        push!(blocklist, "$(blockdata[i]["block_type"]["slug"])/$(blockdata[i]["name"])")
    end
    sort!(blocklist)
    return (blocks = blocklist, )
end

"""
    getblock(blockname::String; api_url::String=PrefectAPI().url)

Makes an `HTTP.get()` call to provided URL endpoint, default endpoint constructed by `PrefectAPI().url`. Returns a Dict containing the Prefect Block specification.
"""
function getblock(blockname::String; api_url::String=PrefectAPI().url)
    block = blockname_components(blockname)
    try
        response = HTTP.request(
            "GET"
            , "$(api_url)/block_types/slug/$(block.slug)/block_documents/name/$(block.name)"
            ; query = ["include_secrets" => "true"]
            , connect_timeout = 3
            , readtimeout = 5
            , retries = 1
            )
        return JSON.parse(String(response.body))
    catch ex
        if typeof(ex) == HTTP.Exceptions.StatusError && ex.status == 404
            @error "Status: $(ex.status): $(String(ex.response.body))" api_url blockname
        elseif typeof(ex) == HTTP.ConnectError
            @error "$(ex.error.ex)" api_url blockname
        else
            rethrow()
        end
    end
end

function blockname_components(blockname::String)
    components = split(blockname, "/")
    slug = components[1]
    name = components[2]
    return (slug=slug, name=name)
end

"""
    makeblock(block_api_data::Dict)

Instantiates a new `PrefectBlock`, choosing the concrete type based on block data returned from the api call for block documents.
"""
function makeblock(block_api_data::Dict)
    blockname = block_api_data["block_type"]["slug"] * "/" * block_api_data["name"]
    blocktype = block_api_data["block_type"]["slug"]

    newblock = @match blocktype begin
        "local-file-system" =>
        LocalFSBlock(
            blockname
            , blocktype
            , block_api_data["data"]["basepath"]
            )
        "s3-bucket" =>
        S3BucketBlock(
            blockname
            , blocktype
            , block_api_data["data"]["bucket_name"]
            , block_api_data["data"]["bucket_folder"]
            , block_api_data["data"]["credentials"]["region_name"]
            , block_api_data["data"]["credentials"]["aws_access_key_id"]
            , block_api_data["data"]["credentials"]["aws_secret_access_key"]
            )
        "aws-credentials" =>
        AWSCredentialsBlock(
            blockname
            , blocktype
            , block_api_data["data"]["region_name"]
            , block_api_data["data"]["aws_access_key_id"]
            , block_api_data["data"]["aws_secret_access_key"]
            )
        "credentialpair" =>
        CredentialPairBlock(
            blockname
            , blocktype
            , block_api_data["data"]["id"]
            , block_api_data["data"]["secret_key"]
            )
        "string" =>
        StringBlock(
            blockname
            , blocktype
            , block_api_data["data"]["value"]
            )
        "secret" =>
        SecretBlock(
            blockname
            , blocktype
            , block_api_data["data"]["value"]
        )
        _ => throw(ArgumentError("""block type "$blocktype" not currently supported in PrefectInterfaces."""))
    end
    return newblock
end
