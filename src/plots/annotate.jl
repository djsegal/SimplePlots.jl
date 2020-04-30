function annotate!(simple_plot::SimplePlot, x_position::Number, y_position::Number, cur_text::PlotText)
  cur_font = Dict()

  ( cur_text.font.family == "" ) || ( cur_font["family"] = cur_text.font.family )
  isnothing( cur_text.font.color ) || ( cur_font["color"] = cur_text.font.color )
  ( cur_text.font.pointsize == -1 ) || ( cur_font["size"] = cur_text.font.pointsize )

  push!(
    simple_plot.layout["annotations"],
    Dict(
      "text" => cur_text.str,
      "textangle" => cur_text.font.rotation,
      "showarrow" => false,
      "x" => collect(x_position),
      "y" => collect(y_position),
      "align" => cur_text.font.halign,
      "valign" => cur_text.font.valign,
      "font" => cur_font
    )
  )

  deepcopy(simple_plot)
end

function annotate!(x_position::Number, y_position::Number, cur_text::PlotText)
  annotate!(_plot, x_position, y_position, cur_text)
end

function annotate!(simple_plot::SimplePlot, x_position::Number, y_position::Number, cur_text::AbstractString)
  annotate!(simple_plot, x_position, y_position, text(cur_text))
end

function annotate!(x_position::Number, y_position::Number, cur_text::AbstractString)
  annotate!(_plot, x_position, y_position, cur_text)
end

export annotate!
