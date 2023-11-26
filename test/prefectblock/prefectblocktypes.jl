using DataFrames

# BLOCKTYPES #
# ========== #

str = StringBlock("string/bytor", "string", "a special string")
@test typeof(str) == StringBlock
@test fieldnames(StringBlock) == (:blockname, :blocktype, :value)
@test str.blockname == "string/bytor"
@test str.blocktype == "string"
@test str.value == "a special string"

password = SecretString("abcd1234")
@test typeof(password) == SecretString
@test fieldnames(SecretString) == (:secret,)
@test password.secret == "abcd1234"
@test repr(password) == "####Secret####"

secretblock = SecretBlock("secret", "necromancer", "abcd1234")
@test typeof(secretblock) == SecretBlock
@test repr(secretblock.value) == "####Secret####"
@test secretblock.value.secret == "abcd1234"
# make sure dump to stdout doesn't contain secret
tmp = tempname()
redirect_stdio(stdout=tmp) do
    dump(secretblock)
end
result = read(tmp, String)
@test ! contains(result, "abcd1234")

awscredentials = AWSCredentialsBlock("aws-creds/signals", "aws-creds", "us-west-2"
    , "AKIAXXXX1234XXXX1234", "GRU999999BOO")
@test typeof(awscredentials) == AWSCredentialsBlock
@test fieldnames(AWSCredentialsBlock) == (:blockname, :blocktype, :region_name, :aws_access_key_id, :aws_secret_access_key)
@test awscredentials.region_name == "us-west-2"
@test awscredentials.aws_access_key_id == "AKIAXXXX1234XXXX1234"
@test awscredentials.aws_secret_access_key.secret == "GRU999999BOO"
@test repr(awscredentials.aws_secret_access_key) == "####Secret####"

creds = CredentialPairBlock("credentialpair/strangiato", "credentialpair", "user123", "passW0rd")
@test typeof(creds) == CredentialPairBlock
@test fieldnames(CredentialPairBlock) == (:blockname, :blocktype, :id, :secret_key)
@test creds.blocktype == "credentialpair"
@test creds.id == "user123"
@test creds.secret_key.secret == "passW0rd"
@test repr(creds.secret_key) == "####Secret####"

s3bucket = S3BucketBlock("s3-bucket/willowdata", "s3-bucket", "cygnus-x1", "willowdata/dev"
    , "us-west-2", "AKIAXXXX1234XXXX1234", "GRU999999BOO")
@test typeof(s3bucket) == S3BucketBlock
@test fieldnames(S3BucketBlock) == (:blockname, :blocktype, :bucket_name, :bucket_folder, :region_name, :aws_access_key_id, :aws_secret_access_key)
@test s3bucket.blockname == "s3-bucket/willowdata"
@test s3bucket.blocktype == "s3-bucket"
@test s3bucket.bucket_name == "cygnus-x1"
@test s3bucket.bucket_folder == "willowdata/dev"
@test s3bucket.region_name == "us-west-2"
@test s3bucket.aws_access_key_id == "AKIAXXXX1234XXXX1234"
@test s3bucket.aws_secret_access_key.secret == "GRU999999BOO"
@test repr(s3bucket.aws_secret_access_key) == "####Secret####"

# LocalFSBlock FUNCTIONS #
# ====================== #
# construct block without Prefect DB
lfsb_basepath = "$PROJECT_ROOT/test/artifacts"
lfsb_data_key = "local-fs-block/data.csv"
lfsb = LocalFSBlock("local-file-system/xanadu", "local-file-system", lfsb_basepath)
lfsb_df = lfsb.read_path(lfsb_data_key)
@test typeof(lfsb_df) == DataFrame
@test nrow(lfsb_df) == 6
@test lfsb_df[1, :item] == "B001"

# write df to a tmp directory and read it back
tmp_basepath = mktempdir()
writeblock = LocalFSBlock("local-file-system/xanadu", "local-file-system", tmp_basepath)
writeblock.write_path(lfsb_data_key, lfsb_df)
read_df = writeblock.read_path(lfsb_data_key)
@test read_df == lfsb_df
