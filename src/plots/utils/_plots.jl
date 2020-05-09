function _plot!(simple_plot::SimplePlot, cur_mode::AbstractString, varargs...; kwargs...)
  vararg_count = length(varargs)
  @assert vararg_count < 3

  haskey(kwargs, :title) && title!(simple_plot, kwargs[:title])

  haskey(kwargs, :xlabel) && xlabel!(simple_plot, kwargs[:xlabel])
  haskey(kwargs, :ylabel) && ylabel!(simple_plot, kwargs[:ylabel])

  haskey(kwargs, :xscale) && xscale!(simple_plot, kwargs[:xscale])
  haskey(kwargs, :yscale) && yscale!(simple_plot, kwargs[:yscale])

  tmp_lims = nothing
  haskey(kwargs, :xlim) && ( tmp_lims = kwargs[:xlim] )
  haskey(kwargs, :xlims) && ( tmp_lims = kwargs[:xlims] )
  isnothing(tmp_lims) || xlims!(simple_plot, tmp_lims)

  tmp_lims = nothing
  haskey(kwargs, :ylim) && ( tmp_lims = kwargs[:ylim] )
  haskey(kwargs, :ylims) && ( tmp_lims = kwargs[:ylims] )
  isnothing(tmp_lims) || ylims!(simple_plot, tmp_lims)

  haskey(kwargs, :xticks) && xticks!(simple_plot, kwargs[:xticks])
  haskey(kwargs, :yticks) && yticks!(simple_plot, kwargs[:yticks])

  if haskey(kwargs, :legend)
    cur_legend = kwargs[:legend]
  elseif haskey(kwargs, :leg)
    cur_legend = kwargs[:leg]
  else
    cur_legend = nothing
  end

  if !isnothing(cur_legend)
    if isa(cur_legend, Bool)
      simple_plot.layout["showlegend"] = cur_legend

      delete!(simple_plot.layout["legend"], "xanchor")
      delete!(simple_plot.layout["legend"], "yanchor")

      delete!(simple_plot.layout["legend"], "x")
      delete!(simple_plot.layout["legend"], "y")

      delete!(simple_plot.layout["legend"], "bordercolor")
      delete!(simple_plot.layout["legend"], "borderwidth")
    else
      @assert !is_repl "No legend placement in REPL"

      simple_plot.layout["showlegend"] = true

      legend_position = cur_legend

      if isa(legend_position, Symbol)
        legend_position = string(legend_position)
      else
        @assert isa(legend_position, AbstractString)
      end

      found_anchor = nothing
      for (y_index, y_anchor) in enumerate(["bottom", "middle", "top"])
        cur_string = ""
        ( y_anchor == "middle" ) || ( cur_string *= y_anchor )
        for (x_index, x_anchor) in enumerate(["left", "center", "right"])
          tmp_string = cur_string
          ( x_anchor == "center" ) || ( tmp_string *= x_anchor )

          ( legend_position == tmp_string ) || continue
          found_anchor = true

          simple_plot.layout["legend"]["xanchor"] = x_anchor
          simple_plot.layout["legend"]["yanchor"] = y_anchor

          simple_plot.layout["legend"]["x"] = string( (x_index-1) / 2 )
          simple_plot.layout["legend"]["y"] = string( (y_index-1) / 2 )

          simple_plot.layout["legend"]["bordercolor"] = "#DDD"
          simple_plot.layout["legend"]["borderwidth"] = "1"

          break
        end
      end

      @assert !isnothing(found_anchor)
    end
  end

  iszero(vararg_count) && return _plot

  if vararg_count == 1
    cur_y = first(varargs)
    cur_x = 1:length(cur_y)
  else
    cur_x = first(varargs)
    cur_y = last(varargs)
  end

  cur_dict = Dict(
    "x" => collect(cur_x),
    "y" => collect(cur_y),
    "mode" => cur_mode
  )

  cur_alpha = nothing
  haskey(kwargs, :alpha) && ( cur_alpha = kwargs[:alpha] )
  haskey(kwargs, :opacity) && ( cur_alpha = kwargs[:opacity] )
  isnothing(cur_alpha) || ( cur_dict["opacity"] = cur_alpha )

  if haskey(kwargs, :color)
    cur_index = kwargs[:color]
    @assert isa(cur_index, Int)
  else
    simple_plot.index += 1
    cur_index = simple_plot.index
  end

  cur_index = 1 + ( (cur_index-1) % length(_palette) )
  cur_color = _palette[cur_index]

  if haskey(kwargs, :xerr)
    cur_dict["error_x"] = Dict(
      "type" => "data",
      "array" => collect(kwargs[:xerr]),
      "opacity" => haskey(kwargs, :fillalpha) ? kwargs[:fillalpha] : (cur_alpha/2),
      "color" => cur_color,
      "width" => 0,
      "thickness" => 2
    )
  end

  if haskey(kwargs, :yerr)
    cur_dict["error_y"] = Dict(
      "type" => "data",
      "array" => collect(kwargs[:yerr]),
      "opacity" => haskey(kwargs, :fillalpha) ? kwargs[:fillalpha] : (cur_alpha/2),
      "color" => cur_color,
      "width" => 0,
      "thickness" => 2
    )
  end

  cur_label = nothing
  haskey(kwargs, :name) && ( cur_label = kwargs[:name] )
  haskey(kwargs, :label) && ( cur_label = kwargs[:label] )

  if !isnothing(cur_label)
    if strip(cur_label) == ""
      cur_dict["showlegend"] = false
    else
      cur_dict["name"] = cur_label
    end
  end

  sub_dict = Dict()
  sub_dict["color"] = cur_color

  if cur_mode == "lines"
    cur_width = nothing
    haskey(kwargs, :width) && ( cur_width = kwargs[:width] )
    haskey(kwargs, :linewidth) && ( cur_width = kwargs[:linewidth] )
    isnothing(cur_width) || ( sub_dict["width"] = cur_width )

    if haskey(kwargs, :linestyle) && string(kwargs[:linestyle]) != "auto"
      sub_dict["dash"] = kwargs[:linestyle]
    end

    cur_dict["line"] = sub_dict
  else
    @assert cur_mode == "markers"

    cur_size = nothing
    haskey(kwargs, :size) && ( cur_size = kwargs[:size] )
    haskey(kwargs, :markersize) && ( cur_size = kwargs[:markersize] )
    isnothing(cur_size) || ( sub_dict["size"] = cur_size )

    cur_dict["marker"] = sub_dict
  end

  push!(simple_plot.data, cur_dict)

  simple_plot
end
