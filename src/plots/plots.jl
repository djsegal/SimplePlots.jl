function plot(varargs...; kwargs...)
  simple_plot = SimplePlot(; kwargs...)
  plot!(simple_plot, varargs...; kwargs...)
end

function scatter(varargs...; kwargs...)
  simple_plot = SimplePlot(; kwargs...)
  scatter!(simple_plot, varargs...; kwargs...)
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
