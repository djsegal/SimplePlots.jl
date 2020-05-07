import Base: show

function show(io::IO, mime::MIME"text/plain", cur_plot::AbstractPlot)
  display(_show(cur_plot))
end

function show(io::IO, mime::MIME, cur_plot::AbstractPlot)
  show(io, mime, _show(cur_plot))
end

function _show(cur_plot::AbstractPlot)
  cur_size, cur_data, cur_layout, cur_config = _show_helper(cur_plot)
  render(cur_size, cur_data, cur_layout, cur_config)
end

function _show_helper(simple_plot::SimplePlot)
  global _plot = simple_plot

  simple_layout = parse_layout(simple_plot)

  simple_data = simple_plot.data
  simple_config = simple_plot.config

  simple_size = simple_plot.size

  return (
    simple_size, simple_data, simple_layout, simple_config
  )
end

function _show_helper(composite_plot::CompositePlot)
  composite_config = nothing
  composite_data = []

  composite_layout_base = nothing
  composite_layout_extra = Dict()

  for (cur_index, simple_plot) in enumerate(composite_plot.plots)
    if isnothing(composite_config)
      composite_config = simple_plot.config
    else
      @assert composite_config == simple_plot.config
    end

    cur_layout_base = deepcopy(simple_plot.layout)

    if haskey(cur_layout_base, "xaxis")
      cur_xaxis = pop!(cur_layout_base, "xaxis")
    else
      cur_xaxis = Dict()
    end

    if haskey(cur_layout_base, "yaxis")
      cur_yaxis = pop!(cur_layout_base, "yaxis")
    else
      cur_yaxis = Dict()
    end

    if ( cur_index == 1 )
      @assert isnothing(composite_layout_base)
      composite_layout_base = cur_layout_base

      isempty(cur_xaxis) || ( composite_layout_extra["xaxis"] = cur_xaxis )
      isempty(cur_yaxis) || ( composite_layout_extra["yaxis"] = cur_yaxis )

      append!(composite_data, simple_plot.data)
      continue
    end

    for (cur_key, cur_value) in cur_layout_base
      if haskey(composite_layout_base, cur_key)
        @assert composite_layout_base[cur_key] == cur_value
      else
        composite_layout_base[cur_key] = cur_value
      end
    end

    isempty(cur_xaxis) || ( composite_layout_extra["xaxis$( cur_index )"] = cur_xaxis )
    isempty(cur_yaxis) || ( composite_layout_extra["yaxis$( cur_index )"] = cur_yaxis )

    tmp_data = deepcopy(simple_plot.data)
    for cur_datum in tmp_data
      cur_datum["xaxis"] = "x" * string(cur_index)
      cur_datum["yaxis"] = "y" * string(cur_index)
    end
    append!(composite_data, tmp_data)
  end

  composite_layout = merge(composite_layout_base, composite_layout_extra)

  width_per_height = composite_plot.size[1]
  width_per_height /= composite_plot.size[2]

  plots_count = length(composite_plot.plots)

  cur_columns = nothing
  best_blanks = Inf
  for cur_method in [ceil, floor]
    tmp_columns = Int(cur_method(sqrt( plots_count * width_per_height )))
    tmp_rows = Int(ceil(plots_count / tmp_columns))

    num_blanks = tmp_columns * tmp_rows - plots_count
    ( num_blanks < best_blanks ) || continue

    best_blanks = num_blanks
    cur_columns = tmp_columns
  end
  cur_rows = Int(ceil(plots_count / cur_columns))

  composite_layout["grid"] = Dict(
    "rows" => string(cur_rows),
    "columns" => string(cur_columns),
    "pattern" => "independent"
  )

  composite_size = composite_plot.size

  return (
    composite_size, composite_data, composite_layout, composite_config
  )
end
