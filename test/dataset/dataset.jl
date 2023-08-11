using PrefectInterfaces
using DataFrames


# Validate Constructors #
# ===================== #
# TODO: write the dataset first, then read it.

# Validate read from LocalFS #
# ========================== #

ds = Dataset(dataset_name="test_julia_dataset", datastore_type="local")
df = read(ds)
@test typeof(df) == DataFrames.DataFrame
@test nrow(df) == 6
@test df[1, :item] == "B001"
