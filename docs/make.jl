using Documenter, SimplePlots

makedocs(;
    modules=[SimplePlots],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/djsegal/SimplePlots.jl/blob/{commit}{path}#L{line}",
    sitename="SimplePlots.jl",
    authors="Dan Segal <dansegal2@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/djsegal/SimplePlots.jl",
)
