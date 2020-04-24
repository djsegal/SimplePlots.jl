function parse_layout(simple_plot::SimplePlot)
  cur_layout = deepcopy(simple_plot.layout)

  if !isempty(simple_plot.xlims)
    cur_lims = simple_plot.xlims
    if cur_layout["xaxis"]["type"] == "log"
      cur_lims = map(log10, cur_lims)
    end
    cur_layout["xaxis"]["range"] = cur_lims
  end

  if !isempty(simple_plot.ylims)
    cur_lims = simple_plot.ylims
    if cur_layout["yaxis"]["type"] == "log"
      cur_lims = map(log10, cur_lims)
    end
    cur_layout["yaxis"]["range"] = cur_lims
  end

  if !isempty(simple_plot.xticks)
    if length(simple_plot.xticks) == 1
      tickvals = first(simple_plot.xticks)
      ticktext = nothing
    else
      tickvals, ticktext = simple_plot.xticks
    end

    if cur_layout["xaxis"]["type"] == "log"
      tickvals = map(log10, tickvals)
    end

    @show tickvals
    cur_layout["xaxis"]["tickvals"] = tickvals
    isnothing(ticktext) || ( cur_layout["xaxis"]["ticktext"] = ticktext )
  end

  if !isempty(simple_plot.yticks)
    if length(simple_plot.yticks) == 1
      tickvals = first(simple_plot.yticks)
      ticktext = nothing
    else
      tickvals, ticktext = simple_plot.yticks
    end

    if cur_layout["yaxis"]["type"] == "log"
      tickvals = map(log10, tickvals)
    end

    cur_layout["yaxis"]["tickvals"] = tickvals
    isnothing(ticktext) || ( cur_layout["yaxis"]["ticktext"] = ticktext )
  end

  cur_layout
end
