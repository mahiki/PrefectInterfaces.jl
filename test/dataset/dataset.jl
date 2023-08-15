using DataFrames
using CSV, Dates
using PrefectInterfaces.Datasets

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
    latest        != today   |  latest   [latest]            dont write to date partition (rare)
    specific      == today   |  rundate  [rundate]
    specific      != today   |  rundate  [rundate]
=#
d1 = Dataset(dataset_name="test_dataset_1")
d2 = Dataset(dataset_name="test_dataset_2", rundate_type="latest", rundate=Date("2020-11-03"))
d3 = Dataset(dataset_name="test_dataset_3", rundate_type="specific", rundate=Dates.today())
d4 = Dataset(dataset_name="test_dataset_4", rundate_type="specific", rundate=Date("2020-11-03"))

@test Datasets.rundate_path_selector(d1) == (read = "extracts/csv/latest/dataset=test_dataset_1/data.csv", write = ["extracts/csv/latest/dataset=test_dataset_1/data.csv", "extracts/csv/dataset=test_dataset_1/rundate=$(Dates.today())/data.csv"])

@test Datasets.rundate_path_selector(d2) == (read = "extracts/csv/latest/dataset=test_dataset_2/data.csv", write = ["extracts/csv/latest/dataset=test_dataset_2/data.csv"])

@test Datasets.rundate_path_selector(d3) == (read = "extracts/csv/dataset=test_dataset_3/rundate=$(Dates.today())/data.csv", write = ["extracts/csv/dataset=test_dataset_3/rundate=$(Dates.today())/data.csv"])

@test Datasets.rundate_path_selector(d4) == (read = "extracts/csv/dataset=test_dataset_4/rundate=2020-11-03/data.csv", write = ["extracts/csv/dataset=test_dataset_4/rundate=2020-11-03/data.csv"])

# Create test dataframe from repo artifact csv #
# ============================================ #
artifactspath = "$PROJECT_ROOT/test/artifacts"
test_data_key = "local-fs-block/data.csv"
test_df = CSV.read("$artifactspath/$test_data_key", DataFrame)

# Validate dataset read/write from mock LocalFSBlock #
# ================================================== #
# create a LocalFSBlock that uses a temp directory
ENV["PREFECT_DATA_BLOCK_LOCAL"] = "local-file-system/working-man"

tmp_basepath = mktempdir()
mock_fs_block = LocalFSBlock("local-file-system/working-man", "local-file-system", tmp_basepath)
mock_pf_fsblock = PrefectBlock("local-file-system/working-man", mock_fs_block)
@test typeof(mock_pf_fsblock) == PrefectBlock


# Dataset read/write latest/specific #
# ================================== #
datas = [d1, d2, d3, d4]

paths = map(x -> write(x, test_df; block=mock_pf_fsblock), datas)

for x in paths
    @test map(isfile, x) |> all
end

# spot check
@test paths[1] == ["$tmp_basepath/extracts/csv/latest/dataset=test_dataset_1/data.csv"
    , "$tmp_basepath/$(d1.dataset_path)"]
@test contains(paths[2][], "extracts/csv/latest/dataset=test_dataset_2/data.csv")

# read back all datasets
read_dfs = map(x -> read(x; block=mock_pf_fsblock), [d1, d2, d3, d4])

@test map(x -> typeof(x) == DataFrame, read_dfs) |> all

# Should not exist: d2 is latest, d3/d4 specific
@test ! isfile("$tmp_basepath/$(d2.dataset_path)")
@test ! isfile("$tmp_basepath/$(d3.latest_path)")
@test ! isfile("$tmp_basepath/$(d4.latest_path)")

# contents as expected
@test nrow.(read_dfs) == [6,6,6,6]
@test map(x -> x[1, :item], read_dfs) == ["B001", "B001", "B001", "B001"]

@test [x == test_df for x in read_dfs] |> all
