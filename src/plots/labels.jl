function title!(simple_plot::SimplePlot, cur_string::AbstractString)
  simple_plot.layout["title"] = cur_string
  validate!(simple_plot)
end

function xlabel!(simple_plot::SimplePlot, cur_string::AbstractString)
  simple_plot.layout["xaxis"]["title"] = cur_string
  validate!(simple_plot)
end

function ylabel!(simple_plot::SimplePlot, cur_string::AbstractString)
  simple_plot.layout["yaxis"]["title"] = cur_string
  validate!(simple_plot)
end

title!(cur_string::AbstractString) = title!(_plot, cur_string)

xlabel!(cur_string::AbstractString) = xlabel!(_plot, cur_string)
ylabel!(cur_string::AbstractString) = ylabel!(_plot, cur_string)

export title!

export xlabel!
export ylabel!
