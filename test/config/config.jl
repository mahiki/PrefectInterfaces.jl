using PrefectInterfaces
using PrefectInterfaces.Datasets

@test PrefectAPI("http://127.0.0.1:4444/api").url == "http://127.0.0.1:4444/api"
api = PrefectAPI()
@test api.url == "http://127.0.0.1:4300/api"
@test typeof(api) == PrefectAPI

dst = Datasets.PrefectDatastoreNames()
@test propertynames(dst) == (:remote, :local)
@test dst.remote == "s3-bucket/willowdata"
@test dst.local == "local-file-system/willowdata"
@test typeof(dst) == Datasets.PrefectDatastoreNames

ndst = Datasets.PrefectDatastoreNames("s3/barchetta", "lfs/spirit-of-radio")
@test ndst.remote == "s3/barchetta"
@test ndst.local == "lfs/spirit-of-radio"
