# Bugfix: PrefectInterfaces authenticate to cloud
* dataframe jobs failing
* makeblock error

## TOPLINE
1. Strategy is add a header argument for API KEY, which if empty will work also for local instance
2. DONE: how to introduce API besides ENV variables. PrefectAPI struct, will move to a global config struct later.


## BUGFIX DOCUMENTATION
    $HOME/.julia/dev/PrefectInterfaces/src/prefectblock/prefectblock.jl
```jl
revise()

api = PrefectAPI("https://api.prefect.cloud/api/accounts/0e3aff3a-16ab-411f-baed-2982e4c82ebd/workspaces/0cd79ef6-aa52-43f7-8357-0f8dc0ff30ce", "pnu_o3RM3DqDGdvGYfIGEJBir0AsCtnIAk4bO9nR")
PrefectAPI("https://api.prefect.cloud/api/accounts/0e3aff3a-16ab-411f-baed-2982e4c82ebd/workspaces/0cd79ef6-aa52-43f7-8357-0f8dc0ff30ce", ####Secret####)

ls(api=api)
(blocks = ["aws-credentials/app-templisher", "credentialpair/trino-creds", "github/cloud", "github/ikeloa-tables-cloud", "local-file-system/datastore", "local-file-system/idioteque", "process/idioteque", "s3-bucket/datastore", "secret/gserviceacct-ikeloa-reports", "slack-webhook/ikeloa-alert-tests", "slack-webhook/ikeloa-alerts", "slack-webhook/zhl-growth-and-experience-wbr", "string/environment"],)

ans.blocks
13-element Vector{String}:
 "aws-credentials/app-templisher"
 "credentialpair/trino-creds"
 "github/cloud"
 "github/ikeloa-tables-cloud"
 "local-file-system/datastore"
 "local-file-system/idioteque"
 "process/idioteque"
 "s3-bucket/datastore"
 "secret/gserviceacct-ikeloa-reports"
 "slack-webhook/ikeloa-alert-tests"
 "slack-webhook/ikeloa-alerts"
 "slack-webhook/zhl-growth-and-experience-wbr"
 "string/environment"

ls(api=api)
(blocks = ["aws-credentials/app-templisher", "credentialpair/trino-creds", "github/cloud", "github/ikeloa-tables-cloud", "local-file-system/datastore", "local-file-system/idioteque", "process/idioteque", "s3-bucket/datastore", "secret/gserviceacct-ikeloa-reports", "slack-webhook/ikeloa-alert-tests", "slack-webhook/ikeloa-alerts", "slack-webhook/zhl-growth-and-experience-wbr", "string/environment"],)

ab = getblock("credentialpair/trino-creds", api=api)
Dict{String, Any} with 12 entries:
  "block_type_id"             => "94a978e3-6f80-406b-ab19-54ccd8a6ba54"
  "block_type_name"           => "CredentialPair"
  "data"                      => Dict{String, Any}("secret_key"=>"xxxxxxx", "id"=>"_ikeloa-trino")
  "block_schema"              => Dict{String, Any}("block_type_id"=>"94a978e3-6f80-406b-ab19-54ccd8a6ba54", "block_type"=>Dict{String, Any}("logo_url"=>"https://i.imgur.com/ArhWDVr.png", "name"=>"Credent…
  "is_anonymous"              => false
  "name"                      => "trino-creds"
  "block_type"                => Dict{String, Any}("logo_url"=>"https://i.imgur.com/ArhWDVr.png", "name"=>"CredentialPair", "code_example"=>"python\nfrom src.blocks.classes.credential_pair import Cred…
  "id"                        => "19726768-a37d-425c-9fd8-eb63fbe339d6"
  "created"                   => "2023-11-21T20:54:36.461919+00:00"
  "updated"                   => "2023-11-21T20:54:36.461935+00:00"
  "block_document_references" => Dict{String, Any}()
  "block_schema_id"           => "d978b0b4-fb89-4947-adf7-bab8f0dd8435"

# Now that PrefectBlock can be constructed from default (dev local) or with api = PrefectAPI
ENV["PREFECT_API_URL"] = "http://127.0.0.1:4204/api";
devls = ls();
devls.blocks
13-element Vector{String}:
 "aws-credentials/app-templisher"
 "credentialpair/trino-creds"
 "github/dev"
 "github/ikeloa-tables-dev"
 "local-file-system/datastore"
 "local-file-system/idioteque"
 "process/idioteque"
 "s3-bucket/datastore"
 "secret/gserviceacct-ikeloa-reports"
 "slack-webhook/ikeloa-alert-tests"
 "slack-webhook/ikeloa-alerts"
 "slack-webhook/zhl-growth-and-experience-wbr"
 "string/environment"

fsblock2 = PrefectBlock("local-file-system/idioteque")
PrefectBlock("local-file-system/idioteque", LocalFSBlock("local-file-system/idioteque", "local-file-system", "/Users/merlinr/prefect-local-deployment/dev", PrefectInterfaces.var"#1#3"{String}("/Users/merlinr/prefect-local-deployment/dev"), PrefectInterfaces.var"#2#4"{String}("/Users/merlinr/prefect-local-deployment/dev")))

dump(fsblock2)
PrefectBlock
  blockname: String "local-file-system/idioteque"
  block: LocalFSBlock
    blockname: String "local-file-system/idioteque"
    blocktype: String "local-file-system"
    basepath: String "/Users/merlinr/prefect-local-deployment/dev"
    read_path: #1 (function of type PrefectInterfaces.var"#1#3"{String})
      basepath: String "/Users/merlinr/prefect-local-deployment/dev"
    write_path: #2 (function of type PrefectInterfaces.var"#2#4"{String})
      basepath: String "/Users/merlinr/prefect-local-deployment/dev"
```

## REPRODUCE
My calls to the PrefectDB have been using a local zero-authentication endpoint.
Methods that call the PrefectDB need to provide the PREFECT_API_KEY to authenticate.

```jl
PREFECT_API_URL
PREFECT_API_KEY
# both present in ENV

using PrefectInterfaces

PrefectAPI()
# PrefectAPI("http://127.0.0.1:4204/api")
ENV["PREFECT_API_URL"]="https://api.prefect.cloud/api/accounts/0e3aff3a-16ab-411f-baed-2982e4c82ebd/workspaces/0cd79ef6-aa52-43f7-8357-0f8dc0ff30ce"

ls()
┌ Warning: no connection.
│   api_url = "https://api.prefect.cloud/api/accounts/0e3aff3a-16ab-411f-baed-2982e4c82ebd/workspaces/0cd79ef6-aa52-43f7-8357-0f8dc0ff30ce"
└ @ PrefectInterfaces ~/.julia/packages/PrefectInterfaces/T1HiK/src/prefectblock/prefectblock.jl:101
HTTP.Exceptions.StatusError(403, "POST", "/api/accounts/0e3aff3a-16ab-411f-baed-2982e4c82ebd/workspaces/0cd79ef6-aa52-43f7-8357-0f8dc0ff30ce/block_documents/filter", HTTP.Messages.Response:
"""
HTTP/1.1 403 Forbidden
...
{"detail":"Not authenticated"}""")
```

## FIX HTTP REQUEST HEADER
[Prefect REST API Docs](https://docs.prefect.io/latest/api-ref/rest-api/)

```jl
# request should have (python)
headers = {"Authorization": f"Bearer {PREFECT_API_KEY}"}

# HTTP.jl
HTTP.request(method, url [, headers [, body]]; <keyword arguments>])

# so ls() has
api_key = ENV["PREFECT_API_KEY"]
api_url = ENV["PREFECT_API_URL"]
resp = HTTP.request(
    "POST"
    , "$(api_url)/block_documents/filter"
    ,   
    , copyheaders=false
)
# HTTP/1.1 200 OK
# 

# AND if there is no KEY, such as for local instance, blank field is all right:
resp = HTTP.request(
    "POST"
    , "http://127.0.0.1:4204/api/block_documents/filter"
    , ["Authorization" => ""]
    , copyheaders=false
)
# also with => "Bearer " still returns result:
# block_type_id" => "88350020-5271-4070-8092-59e191fd2897", "block_type_name" => "AWS Credentials"
just use dev
just pre block ls
# "id" => "9fc99174-6c3a-4cae-9d42-2f41cdc4d3e6"
# this is from dev environment on port 4204
# PASS
```

## TRY LS AGAIN WITH NEW PREFECTAPI FIX
```jl
# from cloud api docs
https://api.prefect.cloud/api/accounts/{account_id}/workspaces/{workspace_id}/block_documents/filter
# profile.toml
PREFECT_API_URL = "https://api.prefect.cloud/api/accounts/0e3aff3a-16ab-411f-baed-2982e4c82ebd/workspaces/0cd79ef6-aa52-43f7-8357-0f8dc0ff30ce"

api = PrefectAPI("https://api.prefect.cloud/api/accounts/0e3aff3a-16ab-411f-baed-2982e4c82ebd/workspaces/0cd79ef6-aa52-43f7-8357-0f8dc0ff30ce", "xxxxxx")

resp = HTTP.post(
    "$(api.url)/block_documents/filter"
    , ["Authorization" => "Bearer $(api.key.secret)"]
    , copyheaders=false
)
HTTP.Messages.Response:
HTTP/1.1 200 OK

resp.body   # has all the information
using JSON
blockdata = JSON.parse(String(resp.body))
# yup its all there
```
DONE.

## HEALTH CHECK
For tests
```jl
# From ReDoc API
https://api.prefect.cloud/api/accounts/{account_id}/workspaces/{workspace_id}/health


check = HTTP.get(ENV["PREFECT_API_URL"] * "/health", ["Authorization" => "Bearer $api_key"])
# 200 OK

# for local Prefect
check = HTTP.get("http://127.0.0.1:4204/health", ["Authorization" => "Bearer "])
# 200 OK
check.status
# 200

```