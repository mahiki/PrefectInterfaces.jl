using PrefectInterfaces

# Validate Env Variables Received #
# =============================== #

@test ENV["PREFECT_LOCAL_DATA_BLOCK"] == "local-file-system/willowdata"
