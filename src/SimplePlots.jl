module SimplePlots

  using UUIDs
  using JSON

  using Printf

  abstract type AbstractPlot end

  include("simple_plot.jl")
  include("composite_plot.jl")

  include("show.jl")
  include("render.jl")

  include("text.jl")
  include("parse_layout.jl")

  include("plots/index.jl")
  include("init.jl")

end
