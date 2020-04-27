function plot(this_plot::SimplePlot, that_plot::SimplePlot, varargs...; kwargs...)
  cur_plots = [
    this_plot, that_plot, varargs...
  ]

  composite_plot = CompositePlot(cur_plots; kwargs...)

  composite_plot
end
