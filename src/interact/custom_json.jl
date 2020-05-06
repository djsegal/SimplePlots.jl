function custom_json(simple_plot::SimplePlot)
  global _plot = simple_plot
  _custom_json(simple_plot)
end

function custom_json(composite_plot::CompositePlot)
  _custom_json(composite_plot)
end

function _custom_json(cur_plot::AbstractPlot)
  cur_layout = parse_layout(cur_plot)

  cur_data = cur_plot.data
  cur_config = cur_plot.config

  return Dict(
    "layout" => cur_layout,
    "data" => cur_data,
    "config" => cur_config,
  )
end
