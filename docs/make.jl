using PrefectInterfaces
using Documenter

DocMeta.setdocmeta!(PrefectInterfaces, :DocTestSetup, :(using PrefectInterfaces); recursive=true)

makedocs(;
    modules=[PrefectInterfaces],
    authors="mahiki <mahiki@users.noreply.github.com>",
    repo="https://github.com/mahiki/PrefectInterfaces.jl/blob/{commit}{path}#{line}",
    sitename="PrefectInterfaces.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mahiki.github.io/PrefectInterfaces.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Introduction" => "index.md"
        , "Demonstration" => "julia-demo.md"
        , "Detailed Explanation" => "usage-and-explanation.md"
        , "Prefect" => [
            "Prefect Install" => "prefect/install-local-prefect-environment.md"
            , "Manual Install" => "prefect/setup-without-justfile.md"
            ]
        , "API" =>  "lib/autodoc.md"
        , "Developers" => "developers.md"
    ]

)

deploydocs(;
    repo="github.com/mahiki/PrefectInterfaces.jl",
    devbranch="main",
)
