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

function SimplePlot(plot_size=(600, 400))
  reset_plot!(
    SimplePlot(
      0, plot_size, [],
      Dict(), Dict(),
      (), (), (), ()
    ); figsize=plot_size
  )
end

function reset_plot!(simple_plot::SimplePlot; kwargs...)
  simple_plot.index = 0

  if haskey(kwargs, :figsize)
    simple_plot.size = kwargs[:figsize]
  else
    simple_plot.size = (600, 400)
  end

  empty!(simple_plot.data)
  empty!(simple_plot.layout)
  empty!(simple_plot.config)

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

  simple_plot
end
