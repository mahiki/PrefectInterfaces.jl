# Data Scientist User Story, and Design Explanation
The problem is to manage routine data ETL or pipeline processing with Prefect and the Python API, while calling Julia fuctions for expressive dataframe transformations or niche high performance custom code. Prefect doesn't provide a Julia SDK (yet), so this package provides components for julia operations that are called from a Prefect orchestration environment. 

Prefect python flows will call Julia `DockerContainer` or `ShellOperations` with parameters such as `{dataset_name: "my_great_dataset", datastore_type: "remote"}`. This isolates the julia environment from the Python one, and avoids sending large data objects through function calls to/from Prefect flows.

This strategy also avoids `pythoncall/juliacall` interoperation, a cool paradigm but one which requires combined python Conda + julia environment management, which is difficult in Prefect deployments. The other side of the coin is that the Julia process needs to define parallel functionality to match the Prefect python application. For example, `PrefectBlock("s3-bucket/willowdata")` which loads block information about `"s3-bucket/willowdata"` from the Prefect server endpoint, or `PrefectInterfaces.Dataset`, which defines a structure for organising input/output/intermediate data file locations to match a similar one in a Prefect application. Accessing block information by name from the julia process greatly simplifies the overall application and reuses the modular paradigm provided by Prefect Blocks.

So now we can orchestrate simple SQL query extracts and data pipelines using the Prefect Python SDK, writing intermediate or final results to a DB or filesystem, and then access these from a julia process using parameters, and references to the same Blocks stored in the Prefect DB. The julia process is orchestrated from Prefect via flow calls to `ShellOperation` or `DockerContainer`. By way of an example implementation, the julia process will read data specified by a `Dataset` instance, and write output to `Dataset` defined locations. This example imaginess a similar `Dataset` class defined in the main python application, it's also an example of the code deplication trade-off mentioned above.

```
┌─────────────┐                   ┌─────────────┐◄───── read ────── ┌───────────┐
│Prefect flow ├────► params ─────►│Julia process├─────► write ────► │file Block │
└─────────────┘                   └─────────────┘                   └───────────┘
```

## WHO WOULD WANT THIS?
The use-case is for scientists or analysts who use Julia and orchestrate data tasks with Prefect. Science and analyst workflows are multi-stage affairs and orchestration is the best solution to managing a proliferation of scheduled jobs. Crucially, the researcher doesn't need or want to set up a production data engineering platform (DBT, Snowflake, Databricks, Azure Data Lake, etc.); this package imagines a very lightweight coder experience. Prefect flows in python are easily understood and quickly deployed (even just locally), and very usable at the individual adhoc level all the way up to large team production environment.

Ultimately, you will desire to deploy some elegant julia process into a production environment, this package can help achieve this via the design considered above.

## DATASET
This is a concrete example of code defined in your Prefect python application that would need a parallel defition in your julia application.
This composite type holds metadata that represents where a data artifact would be written to or read from, and allows a data product to be referenced by a `dataset_name`. The `Dataset` keeps track of file paths and partitions (`rundate`). Other partitions could be implemented, even a Spark/Apache Hive compliant design, if you are a data engineer that likes julia.

Imagine a Prefect flow that reads/writes to locations defined by a python `Dataset` class. When calling a julia process with instructions to read `Dataset(dataset_name="my_cool_dataset")` the prefect flow provides parameters sufficient to construct the `Dataset` instance in the julia process, and the remaining required information is the Prefect server API and names of Prefect blocks required to complete the job. These blocks may define local or remote file systems, details are pulled from the Prefect API endpoint via the `PrefectBlock(blockname::String)` function. The datastore is conceived here as an organized set of files in a Apache hive-ish layout.

```
$HOME/willowdata/projectname/dev/extracts
└── csv
    ├── dataset=my_cool_dataset
    │   ├── rundate=2022-10-23
    │   │   └── data.csv
    │   └── rundate=2022-10-30
    │       └── data.csv
    ├── latest
    │   └── dataset=my_cool_dataset
    │       └── data.csv
```

As a data scientist, it is convenient to reference copious adhoc data artificts by name and let a lightweight orchestration application figure out where to keep it.

## PACKAGE DETAILS
* Interacts with the Prefect Server API to get block information for read/writes, credentials, filesystems, etc.
* The `PrefectBlock(blockname::String)` function requires that a Prefect Server is running, and server endpoint is provided via env variable `PREFECT_API_URL` or a url as keyword argument.
* A good way is to use the `.env` file to specify configuration such as local/remote with a call to `ConfigEnv.dotenv()`

## DEVELOPMENT AND PRODUCTION ENVIRONMENTS
Prefect profiles are good for separating `prod/dev/test` environments, for convenience from the Prefect CLI. Ultimately the API URL defines which Prefect environment you are in. It's useful for these to correspond to git branches. 

The julia environment does not need to be aware of project environment, because it will pull all required information from blocks accessed via each environment's PREFECT_API_URL. For example, in the Prod environment an S3 bucket key "willowdata/prod" would be defined in the `s3-bucket` block. The julia application pulls the s3 bucket and key from block information and otherwise executes in the same way for each environment.

**Managing dev/prod environment with dev/main git branches:** When both main/dev are local, there will be two local prefect DB with different PREFECT_API_URL defined by the Prefect `profiles.toml` profile. The python side of the application will need to distinguish the dev/prod PREFECT_HOME environment variables to define different locations for the prefect DB (which is just a sqlite file). I prefer to do this in a task runner outside of the python application, something like Github Actions, Make, or `just`.

## JUSTFILE
I've found when managing a Prefect orchestrator it is helpful to have a taskrunner program that documents development tasks and executes them for you as well. I use [`just`](https://just.systems/) to launch `dev/main` Prefect DB local servers and manage tasks like Prefect deployment builds ßand running tests before merging and deploying. If you, like most data scientists, like to develop and test on the main branch please ignore this part of the package.
