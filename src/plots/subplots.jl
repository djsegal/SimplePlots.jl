function plot(this_plot::SimplePlot, that_plot::SimplePlot, varargs...)
  cur_plots = [
    this_plot, that_plot, varargs...
  ]

  composite_plot = CompositePlot(cur_plots)

  composite_plot
end
