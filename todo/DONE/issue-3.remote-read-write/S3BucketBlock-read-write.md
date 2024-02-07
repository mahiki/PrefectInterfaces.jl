# PrefectInterfaces.Datasets AWS Path read/write
* AWS package has [AWSCredentials Type](https://juliacloud.github.io/AWS.jl/stable/aws.html#AWS.AWSCredentials)
* AWSS3 package has Path-based interface
* AWS can get credentials from profile `~/.aws/credentials`

DONE: read_path, write_path interface working from block constructor.
NODO: write tests, include Dataset read/write s3 ?? would need s3 available tho.

## WRITE TO INTERFACE
```jl
# details changed for notes
creds = AWSCredentials(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
datapath = "s3://willow-data/xanadu/dev/extracts/csv/dataset=willow.datadatasetset/rundate=2023-10-27/data.csv"
awsconfig = AWSConfig(creds, "us-west-2", "text")
s3data = S3Path(datapath; config=awsconfig)
AWSConfig(
    AWSCredentials(aws_access_key_id, aws_secret_access_key)
    , region_name
    , "text"
    )
object_path(key) = S3Path("s3://$(bucket_name)/$(bucket_folder)/$(key)")
df = CSV.read(s3data, DataFrame)


struct S3BucketBlockTEST <: AbstractPrefectBlock
    blockname::String
    blocktype::String
    bucket_name::String
    bucket_folder::String
    region_name::String
    aws_access_key_id::String
    aws_secret_access_key::SecretString
    read_path::Function
    write_path::Function
   
    S3BucketBlockTEST(blockname, blocktype, bucket_name, bucket_folder, region_name, aws_access_key_id, aws_secret_access_key) = begin
            awsconfig = AWSConfig(
                AWSCredentials(aws_access_key_id, aws_secret_access_key)
                , region_name
                , "text")
            object_path(key) = S3Path(joinpath("s3://", bucket_name, bucket_folder, key), config = awsconfig)
            new(blockname, blocktype, bucket_name, bucket_folder, region_name, aws_access_key_id
                , SecretString(aws_secret_access_key)
                , x -> CSV.read(object_path(x), DataFrame)
                , (x, df) -> CSV.write(object_path(x), df)
            )
        end
end

tests3block = S3BucketBlockTEST(
    s3block.blockname, s3block.block.blocktype, s3block.block.bucket_name
    , s3block.block.bucket_folder, s3block.block.region_name
    , s3block.block.aws_access_key_id, s3block.block.aws_secret_access_key.secret)

# HERE GOES, TRY READ/WRITE S3 FROM BLOCK METHOD
using CSV, DataFrames
# read from basepath s3://willow-data/xanadu/dev/
df = tests3block.read_path("extracts/csv/dataset=xxx.xxxxxxxxxxxx/rundate=2023-10-27/data.csv")

    # 12×10 DataFrame
    #  Row │ report_month_start  report_month  visitors  doo_dads    happy_path_leads  ...
    #      │ Dates.Date          Dates.Date    Int64     Int64            Int64             ...
    # ─────┼────────────────────────────────────────────────────────────────────────────────...
    #    1 │ 2023-01-01          2023-01-01      140168            11058              1653  ...
    #    2 │ 2023-02-01          2023-02-01      188562            15359              2254  ...
    #    3 │ 2023-03-01          2023-03-01      336477            27715              4183  ...
    #=
    ░▒█▀▀▄░▒█▀▀▀█░▒█▀▀▀█░▒█▀▄▀█░░░█░█    
    ░▒█▀▀▄░▒█░░▒█░▒█░░▒█░▒█▒█▒█░░░▀░▀    
    ░▒█▄▄█░▒█▄▄▄█░▒█▄▄▄█░▒█░░▒█░░░▄░▄  =#    

dff = df[1:3, 1:5]
tests3block.write_path("extracts/csv/latest/dataset=issue_3.test_s3_write/data.csv", dff)
#   p"s3://willow-data/xanadu/dev/extracts/csv/latest/dataset=issue_3.test_s3_write/data.csv"
shell> aws s3 ls "s3://willow-data/xanadu/dev/extracts/csv/latest/dataset=issue_3.test_s3_write/" --profile=app-xanadu
    # 2024-02-07 11:35:18        194 data.csv
shell> aws s3 cp ...
shell> cat data.csv
    # report_month_start,report_month,visitors,doo_dads,happy_path_leads
    # 2023-01-01,2023-01-01,140168,11058,1653
    # 2023-02-01,2023-02-01,188562,15359,2254
    # 2023-03-01,2023-03-01,336477,27715,4183
    #=
    ░▒█▀▀▄░▒█▀▀▀█░▒█▀▀▀█░▒█▀▄▀█░░░█░█    
    ░▒█▀▀▄░▒█░░▒█░▒█░░▒█░▒█▒█▒█░░░▀░▀    
    ░▒█▄▄█░▒█▄▄▄█░▒█▄▄▄█░▒█░░▒█░░░▄░▄  =#
```

## EXAMPLE CLI USAGE
Show how to meet `read_path` and `write_path` interface as functions of Dataset type.

```sh
# some data is there on s3 already
aws s3 ls s3://willow-data/xanadu/dev/extracts/csv/ --profile=app-xanadu
    #   PRE dataset=willow.datadatasetset/
    #       |-- rundate=2023-10-27/data.csv
```

```jl
using AWS
using AWSS3

creds = AWSCredentials(#= get credentials from block =#)
path = S3Path($"block.pathname-thingy", config=creds)

CSV.read(path, DataFrame) # returns a dataframe, as current LocalFSBlock.read_path -> DataFrame
ENV["AWS_ACCESS_KEY_ID"] = "XXXX"
ENV["AWS_SECRET_ACCESS_KEY"] = "XXXX"

creds = AWSCredentials(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
datapath = "s3://willow-data/xanadu/dev/extracts/csv/dataset=willow.datadatasetset/rundate=2023-10-27/data.csv"
awsconfig = AWSConfig(creds, "us-west-2", "text")
s3data = S3Path(datapath; config=awsconfig)

df = CSV.read(s3data, DataFrame)
# 12×10 DataFrame
#  Row │ report_month_start  report_month  visitors  doo_dads    happy_path_leads  pre_approval_leads
#      │ Dates.Date          Dates.Date    Int64     Int64            Int64             Int64             
# ─────┼──────────────────────────────────────────────────────────────────────────────────────────────────
#    1 │ 2023-01-01          2023-01-01      140168            11058              1653                 333
#    2 │ 2023-02-01          2023-02-01      188562            15359              2254                 429
#    3 │ 2023-03-01          2023-03-01      336477            27715              4183                 799
#    4 │ 2023-04-01          2023-04-01      419991            35903              5626                1189
# BOOM!

# mess with it and write to new file
testwritepath = "s3://willow-data/xanadu/dev/extracts/csv/latest/dataset=issue_3.s3-read-write/data.csv"

dff = @chain df begin
   select(2:5)
   transform([:happy_path_leads, :visitors] => ByRow((x,y) -> x / y) => :ratio) 
end

CSV.write(S3Path(testwritepath; config=awsconfig), dff)
    # p"s3://willow-data/xanadu/dev/extracts/csv/latest/dataset=issue_3.s3-read-write/data.csv"

shell> aws s3 ls $testwritepath --profile=app-xanadu
    # 2024-02-06 14:49:19        664 data.csv

shell> aws s3 cp $testwritepath . --profile=app-xanadu
    # download: s3://willow-data/xanadu/dev/extracts/csv/latest/dataset=issue_3.s3-read-write/data.csv to ./data.csv

shell> cat data.csv
    # report_month,visitors,doo_dads  ,happy_path_leads,ratio
    # 2023-01-01,140168,11058,1653,0.01179299126762171
    # 2023-02-01,188562,15359,2254,0.011953627984429524
    # 2023-03-01,336477,27715,4183,0.012431756108144093
```

## CONTINUE WITH PREFECTINTERFACES
```jl
using PrefectInterfaces
ENV["PREFECT_API_URL"] = "http://127.0.0.1:4300/api"
ls()
dump(PrefectBlock("s3-bucket/datastore"))
    # PrefectBlock
    # blockname: String "s3-bucket/datastore"
    # block: S3BucketBlock
    #     blockname: String "s3-bucket/datastore"
    #     blocktype: String "s3-bucket"
    #     bucket_name: String "willow-data"
    #     bucket_folder: String "xanadu/dev"
    #     region_name: String "us-west-2"
    #     aws_access_key_id: String "AKIXXXXXXXX"
    #     aws_secret_access_key: SecretString

s3block = PrefectBlock("s3-bucket/datastore")

```