### SimplePlots.jl
##### Plots in 5 seconds or your money back

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://djsegal.github.io/SimplePlots.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://djsegal.github.io/SimplePlots.jl/dev)
[![Build Status](https://travis-ci.com/djsegal/SimplePlots.jl.svg?branch=master)](https://travis-ci.com/djsegal/SimplePlots.jl)
[![Codecov](https://codecov.io/gh/djsegal/SimplePlots.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/djsegal/SimplePlots.jl)

---

+ To load use:

```julia
] add https://github.com/djsegal/SimplePlots.jl
using SimplePlots
```

+ A simple test case is:

```julia
scatter(
  rand(10), label="Scatter", color=4,
  xlabel="x", markersize=6
)

ylabel!("y")

cur_x = 10 .^ (0:0.1:1)
cur_y = rand(0.25:0.05:0.75, length(cur_x))

plot!(cur_x, cur_y, label="Plot", color=3, title="Example")

hline!([1,3] ./ 4, color=2)
vline!(5, linewidth=4, alpha=0.4, linestyle=:dash)

plot!(xlim=(1,15))

ylims!(0,1)
xscale!(:log10)
```

![Example Plot](example.png)
