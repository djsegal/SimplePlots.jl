function plot(varargs...; kwargs...)
  simple_plot = SimplePlot(; kwargs...)
  plot!(simple_plot, varargs...; kwargs...)
end

function scatter(varargs...; kwargs...)
  simple_plot = SimplePlot(; kwargs...)
  scatter!(simple_plot, varargs...; kwargs...)
end

function plot!(simple_plot::SimplePlot, varargs...; kwargs...)
  used_varargs = []
  used_kwargs = Dict(kwargs)

  _has_err = function (cur_vararg)
    all_fields = fieldnames(eltype(cur_vararg[1]))
    ( :(err) in all_fields ) || return false
    ( :(val) in all_fields ) || return false
    true
  end

  if length(varargs) >= 1
    if _has_err(varargs[1])
      push!(used_varargs, getfield.(varargs[1], :val))
      if !haskey(kwargs, :xerr)
        used_kwargs[:xerr] = getfield.(varargs[1], :err)
      end
    else
      push!(used_varargs, varargs[1])
    end
  end

  if length(varargs) >= 2
    if _has_err(varargs[2])
      push!(used_varargs, getfield.(varargs[2], :val))
      if !haskey(kwargs, :yerr)
        used_kwargs[:yerr] = getfield.(varargs[2], :err)
      end
    else
      push!(used_varargs, varargs[2])
    end
  end

  if length(varargs) >= 3
    for cur_vararg in varargs[3:end]
      @assert !_has_err(cur_vararg)
    end
    append!(used_varargs, arargs[3:end])
  end

  _plot!(simple_plot, "lines", used_varargs...; used_kwargs...)
end

function scatter!(simple_plot::SimplePlot, varargs...; kwargs...)
  _plot!(simple_plot, "markers", varargs...; kwargs...)
end

plot!(varargs...; kwargs...) = plot!(_plot, varargs...; kwargs...)
scatter!(varargs...; kwargs...) = scatter!(_plot, varargs...; kwargs...)

export plot, plot!
export scatter, scatter!
