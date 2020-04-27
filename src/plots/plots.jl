function plot(varargs...; kwargs...)
  reset_plot!(_plot; kwargs...)
  plot!(_plot, varargs...; kwargs...)
end

function scatter(varargs...; kwargs...)
  reset_plot!(_plot; kwargs...)
  scatter!(_plot, varargs...; kwargs...)
end

function plot!(simple_plot::SimplePlot, varargs...; kwargs...)
  _plot!(simple_plot, "lines", varargs...; kwargs...)
end

function scatter!(simple_plot::SimplePlot, varargs...; kwargs...)
  _plot!(simple_plot, "markers", varargs...; kwargs...)
end

plot!(varargs...; kwargs...) = plot!(_plot, varargs...; kwargs...)
scatter!(varargs...; kwargs...) = scatter!(_plot, varargs...; kwargs...)

export plot, plot!
export scatter, scatter!
