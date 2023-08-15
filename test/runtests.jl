#=  ================================================================================================
    Test module

    usage options:
        julia --project=. -startup-file=no --eval 'import Pkg; Pkg.test()'
        just test   (will load dotenv)
        ] activate .; test

    note:   tests run in ./test folder
=   ===============================================================================================#

using PrefectInterfaces
using Test
using ConfigEnv
using TOML
using HTTP

const PROJECT_ROOT = pkgdir(PrefectInterfaces)
const PREFECT_PROFILES = TOML.tryparsefile("$PROJECT_ROOT/prefect/profiles.toml")
const ACTIVE_API = begin
    active = PREFECT_PROFILES["active"]
    PREFECT_PROFILES["profiles"][active]["PREFECT_API_URL"]
end

dotenv("$PROJECT_ROOT/.env"; overwrite=false);

println()
println("# SERVER HEALTH CHECK #")
println("# =================== #")
@info "Prefect Server must be running (`prefect server start`)"

include("server/server-connection-check.jl")



println()
println("# BEGIN UNIT TESTS #")
println("# ================ #")
println()

@testset verbose=true "All tests" begin

    @testset "Config" begin

        include("config/config.jl")
        
    end

    @testset "Block types, function tests" begin

        include("prefectblock/prefectblock.jl")
        include("prefectblock/prefectblocktypes.jl")

    end

    @testset "Dataset function" begin

        include("dataset/dataset.jl")

    end
end

println()
