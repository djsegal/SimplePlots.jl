module SimplePlots

  using UUIDs
  using JSON

  include("simple_plot.jl")
  include("parse_layout.jl")

  include("composite_plot.jl")
  include("init.jl")

  include("text.jl")
  include("plots/index.jl")

end
