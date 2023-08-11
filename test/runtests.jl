using Test
using PrefectInterfaces
using HTTP

println("### TODO: all these tests are broken since v0.2.0 change")
# TODO: tests: list blocks, load blocks, write to dataset, read from dataset. see install doc

println()
println("# SERVER HEALTH CHECK #")
println("# =================== #")
println("Prefect Server must be running (`prefect server start`)")

# TODO: just do API_URL here
for (k, v) in PrefectInterfaces.ENV_API
    println("Environment: $k")
    try
        response = HTTP.get(v)
        println("Server $v reponse STATUS: $(response.status) OK")
    catch ex
        println("Prefect Server Not Healthy: $(ex.url) $(ex.error.ex.msg)")
        exit(420) 
    end
end

println()
println("# DUMP ENV BECAUSE FOR SOME REASON THESE DONT SHOW IN TESTS #")
println("# ========================================================= #")
println(ENV)

println()
println("# BEGIN UNIT TESTS #")
println("# ================ #")
println()

@testset "‡‡‡‡‡‡‡‡        All tests                      ‡‡‡‡‡‡‡‡    " begin

    @testset "‡‡‡‡‡‡    Config and environment tests           ‡‡‡‡‡‡    " begin

        include("config/config.jl")
        
    end

    @testset "‡‡‡‡‡‡    Prefect Block types and function tests ‡‡‡‡‡‡    " begin

        include("prefectblock/prefectblock.jl")

    end

    @testset "‡‡‡‡‡‡    Dataset read/write tests               ‡‡‡‡‡‡    " begin

        include("dataset/dataset.jl")

    end
end

println()
