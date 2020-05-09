function xscale!(simple_plot::SimplePlot, cur_symbol::Symbol)
  ( cur_symbol == :log10 ) && ( cur_symbol = :log )

  simple_plot.layout["xaxis"]["exponentformat"] = "power"
  simple_plot.layout["xaxis"]["type"] = string(cur_symbol)

  validate!(simple_plot)
end

function yscale!(simple_plot::SimplePlot, cur_symbol::Symbol)
  ( cur_symbol == :log10 ) && ( cur_symbol = :log )

  simple_plot.layout["yaxis"]["exponentformat"] = "power"
  simple_plot.layout["yaxis"]["type"] = string(cur_symbol)

  validate!(simple_plot)
end

function xlims!(simple_plot::SimplePlot, varargs...)
  @assert 1 <= length(varargs) <= 2

  if length(varargs) == 1
    cur_lims = first(varargs)
    @assert isa(cur_lims, Tuple)
  else
    cur_lims = tuple(varargs...)
  end

  simple_plot.layout["xaxis"]["autorange"] = false
  simple_plot.xlims = cur_lims

  validate!(simple_plot)
end

function ylims!(simple_plot::SimplePlot, varargs...)
  @assert 1 <= length(varargs) <= 2

  if length(varargs) == 1
    cur_lims = first(varargs)
    @assert isa(cur_lims, Tuple)
  else
    cur_lims = tuple(varargs...)
  end

  simple_plot.layout["yaxis"]["autorange"] = false
  simple_plot.ylims = cur_lims

  validate!(simple_plot)
end

xscale!(cur_symbol::Symbol) = xscale!(_plot, cur_symbol)
yscale!(cur_symbol::Symbol) = yscale!(_plot, cur_symbol)

xlims!(cur_lims...) = xlims!(_plot, cur_lims...)
ylims!(cur_lims...) = ylims!(_plot, cur_lims...)

export xscale!
export yscale!

export xlims!
export ylims!
