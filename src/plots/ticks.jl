function xticks!(simple_plot::SimplePlot, cur_ticks)
  if !isa(cur_ticks, Tuple)
    cur_ticks = tuple(collect(cur_ticks))
  end

  simple_plot.xticks = cur_ticks
  simple_plot
end

function yticks!(simple_plot::SimplePlot, cur_ticks)
  if !isa(cur_ticks, Tuple)
    cur_ticks = tuple(collect(cur_ticks))
  end

  simple_plot.yticks = cur_ticks
  simple_plot
end

xticks!(cur_ticks) = xticks!(_plot, cur_ticks)
yticks!(cur_ticks) = yticks!(_plot, cur_ticks)

export xticks!
export yticks!
