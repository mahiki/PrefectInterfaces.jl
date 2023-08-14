using PrefectInterfaces
using DataFrames
using CSV, Dates

# Validate Constructors #
# ===================== #
ds = Dataset(dataset_name="test_julia_dataset", datastore_type="local")
@test typeof(ds) == Dataset
@test fieldnames(Dataset) == (:dataset_name, :datastore_type, :dataset_type, :file_format, :rundate, :rundate_type, :dataset_path, :latest_path, :image_path)
@test ds.dataset_name == "test_julia_dataset"
@test ds.datastore_type == "local"
@test ds.dataset_type == "extracts"
@test ds.file_format == "csv"
@test ds.rundate == Dates.today()
@test ds.rundate_type == "latest"
@test ds.dataset_path == "extracts/csv/dataset=test_julia_dataset/rundate=$(Dates.today())/data.csv"

# Dataset Latest/Specific Selectors #
# ================================= #
#=
    rundate_type  rundate       read     write
    ------------|------------|---------|-----------------------------------------
    latest        == today   |  latest   [latest, rundate]   default option
    latest        != today   |  rundate  [latest]            dont write to date partition (rare)
    specific      == today   |  rundate  [rundate]
    specific      != today   |  rundate  [rundate]
=#
d1 = Dataset(dataset_name="test_dataset_1")
d2 = Dataset(dataset_name="test_dataset_2", rundate_type="latest", rundate=Date("2020-11-03"))
d3 = Dataset(dataset_name="test_dataset_3", rundate_type="specific", rundate=Dates.today())
d4 = Dataset(dataset_name="test_dataset_4", rundate_type="specific", rundate=Date("2020-11-03"))

@test PrefectInterfaces.rundate_path_selector(d1) == (read = "extracts/csv/latest/dataset=test_dataset_1/data.csv", write = ["extracts/csv/latest/dataset=test_dataset_1/data.csv", "extracts/csv/dataset=test_dataset_1/rundate=$(Dates.today())/data.csv"])

@test PrefectInterfaces.rundate_path_selector(d2) == (read = "extracts/csv/dataset=test_dataset_2/rundate=2020-11-03/data.csv", write = ["extracts/csv/latest/dataset=test_dataset_2/data.csv"])

@test PrefectInterfaces.rundate_path_selector(d3) == (read = "extracts/csv/dataset=test_dataset_3/rundate=$(Dates.today())/data.csv", write = ["extracts/csv/dataset=test_dataset_3/rundate=$(Dates.today())/data.csv"])

@test PrefectInterfaces.rundate_path_selector(d4) == (read = "extracts/csv/dataset=test_dataset_4/rundate=2020-11-03/data.csv", write = ["extracts/csv/dataset=test_dataset_4/rundate=2020-11-03/data.csv"])

# Validate read/write from LocalFS #
# ================================ #

# data artifact path, write df to tmp block location
artifactspath = "$PROJECT_ROOT/test/artifacts"
test_data_key = "local-fs-block/data.csv"
test_df = CSV.read("$artifactspath/$test_data_key", DataFrame)

# create a LocalFSBlock that uses a temp directory
ENV["PREFECT_DATA_BLOCK_LOCAL"] = "local-file-system/working-man"

tmp_basepath = mktempdir()
test_fs_block = LocalFSBlock("local-file-system/working-man", "local-file-system", tmp_basepath)
test_pf_block = PrefectBlock("local-file-system/working-man", test_fs_block)
@test typeof(test_pf_block) == PrefectBlock


data_path = write(ds, test_df; block=test_pf_block)
@test isfile(data_path)

df = read(ds; block=test_pf_block)

@test typeof(df) == DataFrames.DataFrame
@test nrow(df) == 6
@test df[1, :item] == "B001"
@test df == test_df
