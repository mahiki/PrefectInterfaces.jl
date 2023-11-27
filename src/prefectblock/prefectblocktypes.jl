using CSV, DataFrames

struct StringBlock <: AbstractPrefectBlock
    blockname::String
    blocktype::String
    value::String
end

"""
	SecretString(secret::String) <:Any

A struct for storing secret values with overrides of `show` and `dump` to prevent its field from being exposed in plaintext in logs. The secret field is accessible via the `secret` field.

*NOTE:* This is not an ecrypted secrets store, it is a log obfuscator.

# Example:
```jldoctest
julia> using PrefectInterfaces

julia> password = SecretString("abcd1234")
####Secret####

julia> show(password)
####Secret####
julia> password.secret
"abcd1234"
```
"""
struct SecretString
    secret::String
end
Base.show(io::IO, s::SecretString) = print(io, "####Secret####")
Base.dump(io::IOContext, s::SecretString, n::Int64, indent) = print(io, "SecretString")

"""
    SecretBlock(blockname::String, blocktype::String, value::SecretString) <: AbstractPrefectBlock

A struct for storing a Prefect Block with a SecretString as value field. This permits retrieving secrets from the Prefect Server/Prefect Cloud. The secret field is accessible via the `value.secret` field.

*NOTE:* This is not an ecrypted secrets store, it is a log obfuscator.

# Example:
```jldoctest
julia> using PrefectInterfaces

julia> secretblock = SecretBlock("secret", "necromancer", "abcd1234")
SecretBlock("secret", "necromancer", ####Secret####)

julia> dump(secretblock, maxdepth = 10)
SecretBlock
  blockname: String "secret"
  blocktype: String "necromancer"
  value: SecretString

julia> secretblock.value.secret
"abcd1234"
```
"""
struct SecretBlock <: AbstractPrefectBlock
    blockname::String
    blocktype::String
    value::SecretString
    SecretBlock(blockname, blocktype, value) = 
        new(blockname, blocktype, SecretString(value))
end

"""
    LocalFSBlock(blockname::String, blocktype::String, basepath::String)

Corresponds with the Prefect LocalFileSystem block. Attached functions:

    read_path("path/to/file.csv")
    write_path("path/to/file.csv", df::AbstractDataFrame)
Returns or writes a DataFrame file at "LocalFSBlock.basepath/path/to/file.csv".

# Examples:
```julia
julia> fsblock = PrefectBlock("local-file-system/willowdata");

julia> df = fsblock.block.read_path("extracts/csv/dataset=test_table/rundate=2023-05-25/data.csv")
1×2 DataFrame
 Row │ column1                            result
     │ String                             String7
─────┼────────────────────────────────────────────
   1 │ If you can select this table you…  PASSED

```
"""
struct LocalFSBlock <: AbstractPrefectBlock
    blockname::String
    blocktype::String
    basepath::String
    read_path::Function
    write_path::Function
    # TODO: should be to filesystem write, CSV write function composable if data is csv
    LocalFSBlock(blockname, blocktype, basepath) =
        new(blockname, blocktype, basepath
            , x -> CSV.read("$basepath/$x", DataFrame)
            , (x, df) -> begin
                mkpath(dirname("$basepath/$x"))
                CSV.write("$basepath/$x", df)
                end
        )
end

struct AWSCredentialsBlock <: AbstractPrefectBlock
    blockname::String
    blocktype::String
    region_name::String
    aws_access_key_id::String
    aws_secret_access_key::SecretString
    AWSCredentialsBlock(
        blockname, blocktype, region_name, aws_access_key_id, aws_secret_access_key) = 
        new(blockname, blocktype, region_name, aws_access_key_id
        , SecretString(aws_secret_access_key)
        )
end

struct CredentialPairBlock <: AbstractPrefectBlock
    blockname::String
    blocktype::String
    id::String
    secret_key::SecretString
    CredentialPairBlock(blockname, blocktype, id, secret_key) = 
        new(blockname, blocktype, id, SecretString(secret_key)
        )
end

struct S3BucketBlock <: AbstractPrefectBlock
    blockname::String
    blocktype::String
    bucket_name::String
    bucket_folder::String
    region_name::String
    aws_access_key_id::String
    aws_secret_access_key::SecretString
    S3BucketBlock(
        blockname, blocktype, bucket_name, bucket_folder, region_name, aws_access_key_id, aws_secret_access_key) =
        new(blockname, blocktype, bucket_name, bucket_folder, region_name, aws_access_key_id, SecretString(aws_secret_access_key)
        )
    # TODO: read_path/write_path function
end
