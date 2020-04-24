module SimplePlots

  using UUIDs
  using JSON
  using PlotThemes
  using PlotUtils
  using Colors

  include("simple_plot.jl")
  include("parse_layout.jl")

  include("composite_plot.jl")
  include("init.jl")

  include("text.jl")
  include("plot.jl")

end
