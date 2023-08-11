using PrefectInterfaces
using DataFrames

# Validate Constructors #
# ===================== #

password = SecretString("abcd1234")
@test repr(password) == "####Secret####"
@test password.secret == "abcd1234"

# this changes depending on `just test` or julia --eval 'Pkg.test()' and current branch
defaultendpoint = PrefectAPI()
@test defaultendpoint.url == "http://127.0.0.1:4200/api"

devendpoint = PrefectAPI("http://127.0.0.1:4244/api")
@test devendpoint.url == "http://127.0.0.1:4244/api"

defaultfsblock = PrefectBlock("local-file-system/willowdata")
@test defaultfsblock.blockname == "local-file-system/willowdata"
@test defaultfsblock.blocktype == "local-file-system"
@test defaultfsblock.name == "datastore"
@test defaultfsblock.env == "main"
@test defaultfsblock.api == "http://127.0.0.1:4200/api"

devfsblock = PrefectBlock("local-file-system/willowdata", "dev")
@test devfsblock.blockname == "local-file-system/willowdata"
@test devfsblock.slug == "local-file-system"
@test devfsblock.name == "datastore"
@test devfsblock.env == "dev"
@test devfsblock.api == "http://127.0.0.1:4209/api"

mains3block = PrefectBlock("s3-bucket/willowdata", "main")
@test mains3block.blockname == "s3-bucket/willowdata"
@test mains3block.slug == "s3-bucket"
@test mains3block.name == "datastore"
@test mains3block.env == "main"
@test mains3block.api == "http://127.0.0.1:4200/api"

awscredentials = AWSCredentialsBlock("us-west-2", "AKIAXXXX1234XXXX1234", "GRU999999BOO")
@test awscredentials.region_name == "us-west-2"
@test awscredentials.aws_access_key_id == "AKIAXXXX1234XXXX1234"
@test repr(awscredentials.aws_secret_access_key) == "####Secret####"
@test awscredentials.aws_secret_access_key.secret == "GRU999999BOO"


# Validate load from Prefect Server #
# ================================= #

defaultfsloaded = load(defaultfsblock)
@test typeof(defaultfsloaded) == PrefectInterfaces.LocalFSBlock
@test defaultfsloaded.blockname == "local-file-system/willowdata"
@test defaultfsloaded.blocktype == "local-file-system"
@test defaultfsloaded.basepath == expanduser("~/willowdata/projectname/main")

devfsloaded = load(devfsblock)
@test typeof(devfsloaded) == PrefectInterfaces.LocalFSBlock
@test devfsloaded.blockname == "local-file-system/willowdata"
@test devfsloaded.blocktype == "local-file-system"
@test devfsloaded.basepath == expanduser("~/willowdata/projectname/dev")

defaults3loaded = load(mains3block)
@test typeof(defaults3loaded) == PrefectInterfaces.S3BucketBlock
@test defaults3loaded.blockname == "s3-bucket/willowdata"
@test defaults3loaded.blocktype == "s3-bucket"
@test typeof(defaults3loaded.credentials) == AWSCredentialsBlock
@test repr(defaults3loaded.credentials.aws_secret_access_key) == "####Secret####"


# Validate read from LocalFSBlock #
# =============================== #

lfsb_basepath = expanduser("~/repo/julia-pkgs/PrefectInterfaces/test/artifacts")
lfsb_data_key = "local-fs-block/data.csv"
lfsb = LocalFSBlock("local-file-system/willowdata", "local-file-system", lfsb_basepath)
lfsb_df = lfsb.read_path(lfsb_data_key)
@test typeof(lfsb_df) == DataFrames.DataFrame
@test nrow(lfsb_df) == 6
@test lfsb_df[1, :item] == "B001"
