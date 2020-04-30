import UnicodePlots
import UnicodePlots: BrailleCanvas, nrows
import UnicodePlots: lineplot!, scatterplot!

function render_unicode(cur_size, cur_data, cur_layout, cur_config)

  work_layout = deepcopy(cur_layout)

  cur_plot, has_legend, is_linear_x, is_linear_y = (
    _configure_repl_layout(cur_size, cur_data, work_layout)
  )

  if isempty(cur_data)
    return cur_plot
  end

  # repl doesn't allow legend placement
  @assert isempty(work_layout["legend"])
  delete!(work_layout, "legend")

  # no annotations in repl
  delete!(work_layout, "annotations")

  work_config = deepcopy(cur_config)
  delete!(work_config, "responsive")
  @assert isempty(work_config)

  for (cur_index, cur_datum) in enumerate(cur_data)
    @assert cur_datum["mode"] in ["lines", "markers"]

    work_datum = deepcopy(cur_datum)
    singular_mode = cur_datum["mode"][1:end-1]

    if cur_datum["mode"] == "lines"
      plotfunc = lineplot!
    else
      plotfunc = scatterplot!
    end

    cur_kwargs = Dict()
    cur_kwargs[:color] = Symbol(cur_datum[singular_mode]["color"])

    if haskey(cur_datum, "showlegend")
      @assert !cur_datum["showlegend"]
      @assert !haskey(cur_datum, "name")
      delete!(work_datum, "showlegend")
    elseif haskey(cur_datum, "name")
      cur_label = cur_datum["name"]
      if length(cur_label) > max_label_length
        cur_label = cur_label[1:(max_label_length-1)] * "…"
      end

      if has_legend
        cur_kwargs[:name] = cur_label
      end
      delete!(work_datum, "name")
    end

    cur_x = cur_datum["x"]
    cur_y = cur_datum["y"]

    is_linear_x || ( cur_x = log10.(float.(cur_x)) )
    is_linear_y || ( cur_y = log10.(float.(cur_y)) )

    plotfunc(
      cur_plot, cur_x, cur_y; cur_kwargs...
    )

    delete!(work_datum[singular_mode], "color")
    @assert isempty(work_datum[singular_mode])
    delete!(work_datum, singular_mode)

    delete!(work_datum, "mode")
    delete!(work_datum, "x")
    delete!(work_datum, "y")

    isempty(work_datum) || @show work_datum
    @assert isempty(work_datum)
  end

  @assert isempty(work_layout["shapes"])
  delete!(work_layout, "shapes")
  @assert isempty(work_layout)

  for (k,v) in work_layout
    @show (k,v)
  end

  cur_plot
end

function _configure_repl_layout(cur_size, cur_data, work_layout)
  println(404)

  size_x, size_y = cur_size

  has_legend = work_layout["showlegend"]
  delete!(work_layout, "showlegend")

  if isempty(cur_data)
    max_label_length = 0
  else
    max_label_length = maximum(
      length.(map(
        cur_datum -> haskey(cur_datum, "name") ? cur_datum["name"] : "", cur_data
      ))
    )

    max_label_length = min(16, max_label_length)

    if has_legend
      size_x -= max_label_length
    end
  end

  _get_lims(x) = collect(extrema(Base.Iterators.flatten(
    map(cur_datum -> cur_datum[x], cur_data)
  )))

  function _get_extrema(x)
    if haskey(work_layout["$(x)axis"], "range")
      @assert work_layout["$(x)axis"]["autorange"] == false
      cur_extrema = work_layout["$(x)axis"]["range"]
      delete!(work_layout["$(x)axis"], "range")
    else
      @assert work_layout["$(x)axis"]["autorange"] == true
      if isempty(cur_data)
        cur_extrema = (1, 10)
      else
        cur_extrema = _get_lims(x)
      end
    end

    delete!(work_layout["$(x)axis"], "autorange")
    return cur_extrema
  end

  if isempty(cur_data)
    min_x, max_x = _get_extrema("x")
    min_y, max_y = _get_extrema("y")
  else
    min_x, max_x = _get_extrema("x")
    min_y, max_y = _get_extrema("y")
  end

  function _is_linear(x)
    cur_is_linear = work_layout["$(x)axis"]["type"] == "linear"
    if !cur_is_linear
      @assert work_layout["$(x)axis"]["type"] == "log"
    end
    delete!(work_layout["$(x)axis"], "type")

    cur_is_linear
  end

  is_linear_x = _is_linear("x")
  is_linear_y = _is_linear("y")

  if is_linear_x
    origin_x = min_x
    width = max_x - min_x
  else
    origin_x = log10(min_x)
    width = log10(max_x) - log10(min_x)
  end

  if is_linear_y
    origin_y = min_y
    height = max_y - min_y
  else
    origin_y = log10(min_y)
    height = log10(max_y) - log10(min_y)
  end

  # ignore desired format for repl
  delete!(work_layout["xaxis"], "exponentformat")
  delete!(work_layout["yaxis"], "exponentformat")

  if haskey(work_layout["xaxis"], "title")
    cur_xlabel = work_layout["xaxis"]["title"]
    delete!(work_layout["xaxis"], "title")
  else
    cur_xlabel = ""
  end

  if haskey(work_layout["yaxis"], "title")
    cur_ylabel = work_layout["yaxis"]["title"]
    delete!(work_layout["yaxis"], "title")
  else
    cur_ylabel = ""
  end

  @assert isempty(work_layout["xaxis"])
  @assert isempty(work_layout["yaxis"])

  delete!(work_layout, "xaxis")
  delete!(work_layout, "yaxis")

  cur_canvas = BrailleCanvas(
    size_x, size_y, width=width, height=height,
    origin_x=origin_x, origin_y=origin_y
  )

  if is_linear_x
    if is_linear_y
      border = :solid
    else
      border = :ascii
    end
  else
    if is_linear_y
      border = :dashed
    else
      border = :dotted
    end
  end

  if !is_linear_x
    if strip(cur_xlabel) == ""
      cur_xlabel = "log"
    else
      cur_xlabel = "log " * cur_xlabel
    end
  end

  if haskey(work_layout, "title")
    cur_title = work_layout["title"]
    delete!(work_layout, "title")
  else
    cur_title = ""
  end

  cur_plot = UnicodePlots.Plot(
    cur_canvas; title = cur_title,
    xlabel = cur_xlabel, border=border
  )

  function _annotate!(varargs...; color=:light_black)
    UnicodePlots.annotate!(cur_plot, varargs..., color=color)
  end

  ylabel_index = Int(floor(nrows(cur_canvas)/2))

  if strip(cur_ylabel) == ""
    if !is_linear_y
      _annotate!(:l, ylabel_index, "log", color=:gray)
    end
  else
    _annotate!(:l, ylabel_index, cur_ylabel, color=:gray)

    if !is_linear_y
      log_label = "log"
      cur_diff = length(cur_ylabel) - length(log_label)

      log_label = lpad(log_label, length(log_label) + Int(floor(cur_diff/2)))
      log_label = rpad(log_label, length(cur_ylabel))

      _annotate!(:l, ylabel_index-1, log_label, color=:gray)
    end
  end

  function _clean_string(cur_value)
    rounded_value = round(cur_value, sigdigits=3)

    if ( abs(rounded_value) % 1 ) < ( 1e3 * eps() )
      string_value = string(Int(rounded_value))
    elseif 0.1 <= abs(rounded_value) < 1e4
      string_value = string(rounded_value)
    else
      tmp_coeff, tmp_exponent = split(@sprintf("%.2e", rounded_value), "e")
      tmp_coeff = rstrip(rstrip(tmp_coeff, '0'), '.')

      string_value = tmp_coeff * "e" * tmp_exponent
    end

    string_value
  end

  _annotate!(:l, nrows(cur_canvas), _clean_string(min_y))
  _annotate!(:l, 1, _clean_string(max_y))
  _annotate!(:bl, _clean_string(min_x))
  _annotate!(:br, _clean_string(max_x))

  return (cur_plot, has_legend, is_linear_x, is_linear_y)

end
