import Base: show

mutable struct CompositePlot <: AbstractPlot
  plots::Vector{SimplePlot}
  size::Tuple

  function CompositePlot(plots, plot_size)
    @assert !is_repl "No composite plots in REPL"
    new(plots, plot_size)
  end
end

function CompositePlot(cur_plots=[]; kwargs...)
  cur_plot = nothing
  if haskey(kwargs, :figsize)
    cur_plot = CompositePlot(cur_plots, kwargs[:figsize])
  else
    cur_plot = CompositePlot(cur_plots, default_plot_size)
  end
  cur_plot
end
