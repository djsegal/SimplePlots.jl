module SimplePlots

  using UUIDs
  using JSON

  using Printf
  using DataStructures

  using IJulia.CommManager
  using Observables

  abstract type AbstractPlot end

  include("simple_plot.jl")
  include("composite_plot.jl")

  include("show.jl")
  include("render.jl")

  include("text.jl")
  include("parse_layout.jl")

  include("plots/index.jl")
  include("interact/index.jl")

  include("init.jl")

end
