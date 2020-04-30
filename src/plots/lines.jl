function hline(varargs...; kwargs...)
  simple_plot = SimplePlot(; kwargs...)
  hline!(simple_plot, varargs...; kwargs...)
end

function vline(varargs...; kwargs...)
  simple_plot = SimplePlot(; kwargs...)
  vline!(simple_plot, varargs...; kwargs...)
end

function hline!(simple_plot::SimplePlot, varargs...; kwargs...)
  _line!(simple_plot, "x", varargs...; kwargs...)
end

function vline!(simple_plot::SimplePlot, varargs...; kwargs...)
  _line!(simple_plot, "y", varargs...; kwargs...)
end

hline!(varargs...; kwargs...) = hline!(_plot, varargs...; kwargs...)
vline!(varargs...; kwargs...) = vline!(_plot, varargs...; kwargs...)

export hline, hline!
export vline, vline!
