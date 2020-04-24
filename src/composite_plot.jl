import Base: show

mutable struct CompositePlot
  plots::Vector{SimplePlot}
  size::Tuple
end

CompositePlot(cur_plots=[]) = CompositePlot(cur_plots, (600, 400))

function show(io::IO, simple_plot::CompositePlot)
  @assert false
end

function show(io::IO, m::MIME"text/plain", composite_plot::CompositePlot)
  cur_plot_id = string(UUIDs.uuid4())
  cur_plot_div = "js-plot-" * string(cur_plot_id)

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

  display(HTML(
    """
      <div id="$(cur_plot_div)" style="width:$(composite_plot.size[1])px;height:$(composite_plot.size[2])px;"></div>

      <script>
        plotDiv = document.getElementById('$(cur_plot_div)');

        Plotly.newPlot(
          plotDiv,
          $(JSON.json(composite_data)),
          $(JSON.json(composite_layout)),
          $(JSON.json(composite_config))
        );
      </script>
    """
  ))
end
