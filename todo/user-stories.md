# User Stories
* assume prefect server running, data connections and locations are stored in Prefect blocks.
* user has access to Prefect Dashboard, and the configuration (ie `.env` file)

## LIST OF USER STORIES
1. Julia REPL, read some data located from Prefect managed data store
2. Julia REPL, write some data to the Prefect managed data store
3. Call a Julia process from a flow
4. Schedule a Prefect job that calls a Julia process

## 1. JULIA REPL, READ SOME DATA
Q: how does julia session know what PREFECT_API_URL to call? Once you have that you dont need to know dev/main env.

```jl
using PrefectInterfaces

ds = Dataset(dataset_name="customer_things_daily", datastore_type="local")

df = PrefectInterfaces.read(ds)
```

## 2. JULIA REPL, WRITE SOME DATA

## 3. CALL A JULIA PROCESS FROM A FLOW
```jl
# Parameters sent to julia:
#   PREFECT_API_URL
#   dataset_name
#   [datastor_type=, dataset_type, rundate_type, ]

```

## 4. SCHEDULE A PREFECT JOB THAT CALLS A JULIA PROCESS
