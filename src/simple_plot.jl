mutable struct SimplePlot <: AbstractPlot
  index::Int
  size::Tuple
  data::Vector{AbstractDict}
  layout::AbstractDict
  config::AbstractDict
  xlims::Tuple
  ylims::Tuple
  xticks::Tuple
  yticks::Tuple
end

function SimplePlot(; kwargs...)
  if haskey(kwargs, :figsize)
    plot_size = kwargs[:figsize]
  else
    plot_size = default_plot_size
  end

  simple_plot = SimplePlot(
    0, plot_size, [],
    Dict(), Dict(),
    (), (), (), ()
  )

  simple_plot.config["responsive"] = true

  simple_plot.layout["xaxis"] = Dict()
  simple_plot.layout["yaxis"] = Dict()

  simple_plot.layout["legend"] = Dict()

  simple_plot.layout["annotations"] = Vector{AbstractDict}()
  simple_plot.layout["showlegend"] = true

  simple_plot.layout["xaxis"]["autorange"] = true
  simple_plot.layout["yaxis"]["autorange"] = true

  simple_plot.layout["xaxis"]["type"] = "linear"
  simple_plot.layout["yaxis"]["type"] = "linear"

  simple_plot.layout["shapes"] = []

  global _plot = simple_plot

  simple_plot
end
