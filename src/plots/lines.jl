function hline(varargs...; kwargs...)
  empty!(_plot)
  hline!(_plot, varargs...; kwargs...)
end

function vline(varargs...; kwargs...)
  empty!(_plot)
  vline!(_plot, varargs...; kwargs...)
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
