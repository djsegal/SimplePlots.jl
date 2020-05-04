function custom_json(simple_plot::SimplePlot)
  global _plot = simple_plot

  cur_layout = parse_layout(simple_plot)

  cur_data = simple_plot.data
  cur_config = simple_plot.config

  return Dict(
    "layout" => cur_layout,
    "data" => cur_data,
    "config" => cur_config,
  )
end
