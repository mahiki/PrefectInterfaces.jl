using PrefectInterfaces
using Test
using Documenter
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

include("server/server-connection-check.jl")
server = server_connection_check()


@testset verbose=true "All tests" begin

    @testset "Config" begin

        include("config/config.jl")
        
    end

    if ! server
        @warn "Skipping tests that call the server"
    else
        @testset "Block types, function tests" begin

        include("prefectblock/prefectblock.jl")
        include("prefectblock/prefectblocktypes.jl")

        end
    end

    @testset "Dataset function" begin

        include("dataset/dataset.jl")

    end

    # TODO: doctests not importing PI names
    doctest(PrefectInterfaces)

end

if ! server
    println()
    println("  SERVER DEPENDENT TESTS WERE SKIPPED")
end

println()
