import Base: show

mutable struct CompositePlot <: AbstractPlot
  plots::Vector{SimplePlot}
  size::Tuple
end

function CompositePlot(cur_plots=[]; kwargs...)
  cur_plot = nothing
  if haskey(kwargs, :figsize)
    cur_plot = CompositePlot(cur_plots, kwargs[:figsize])
  else
    cur_plot = CompositePlot(cur_plots, (600, 400))
  end
  cur_plot
end
