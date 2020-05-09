function _line!(simple_plot::SimplePlot, cur_mode::AbstractString, varargs...; kwargs...)
  if length(varargs) == 1
    first_item = first(varargs)

    if isa(first_item, Array)
      cur_list = first_item
    else
      cur_list = collect(first_item)
    end
  else
    cur_list = collect(varargs)
  end

  init_dict = Dict{Any,Any}(
    "x0" => 0,
    "x1" => 1,
    "y0" => 0,
    "y1" => 1,
  )

  for cur_entry in cur_list
    cur_dict = deepcopy(init_dict)

    if cur_mode == "x"
      cur_dict["y0"] = string(cur_entry)
      cur_dict["y1"] = string(cur_entry)
      cur_dict["xref"] = "paper"
    else
      @assert cur_mode == "y"

      cur_dict["x0"] = string(cur_entry)
      cur_dict["x1"] = string(cur_entry)
      cur_dict["yref"] = "paper"
    end

    cur_dict["type"] = "line"

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

    sub_dict = Dict()
    sub_dict["color"] = cur_color

    cur_width = nothing
    haskey(kwargs, :width) && ( cur_width = kwargs[:width] )
    haskey(kwargs, :linewidth) && ( cur_width = kwargs[:linewidth] )
    isnothing(cur_width) || ( sub_dict["width"] = cur_width )

    if haskey(kwargs, :linestyle) && string(kwargs[:linestyle]) != "auto"
      sub_dict["dash"] = kwargs[:linestyle]
    end

    cur_dict["line"] = sub_dict

    push!(simple_plot.layout["shapes"], cur_dict)
  end

  simple_plot
end
