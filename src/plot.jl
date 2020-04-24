function plot(this_plot::SimplePlot, that_plot::SimplePlot, varargs...)
  cur_plots = [
    this_plot, that_plot, varargs...
  ]

  composite_plot = CompositePlot(cur_plots)

  composite_plot
end

function plot(varargs...; kwargs...)
  empty!(_plot)
  plot!(_plot, varargs...; kwargs...)
end

function scatter(varargs...; kwargs...)
  empty!(_plot)
  scatter!(_plot, varargs...; kwargs...)
end

function _plot!(simple_plot::SimplePlot, cur_mode::AbstractString, varargs...; kwargs...)
  vararg_count = length(varargs)
  @assert vararg_count < 3

  haskey(kwargs, :title) && title!(simple_plot, kwargs[:title])

  haskey(kwargs, :xlabel) && xlabel!(simple_plot, kwargs[:xlabel])
  haskey(kwargs, :ylabel) && ylabel!(simple_plot, kwargs[:ylabel])

  haskey(kwargs, :xscale) && xscale!(simple_plot, kwargs[:xscale])
  haskey(kwargs, :yscale) && yscale!(simple_plot, kwargs[:yscale])

  haskey(kwargs, :xlims) && xlims!(simple_plot, kwargs[:xlims])
  haskey(kwargs, :ylims) && ylims!(simple_plot, kwargs[:ylims])

  haskey(kwargs, :xticks) && xticks!(simple_plot, kwargs[:xticks])
  haskey(kwargs, :yticks) && yticks!(simple_plot, kwargs[:yticks])

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

  if haskey(kwargs, :xerr)
    cur_dict["error_x"] = Dict(
      "type" => "data",
      "array" => kwargs[:xerr]
    )
  end

  if haskey(kwargs, :yerr)
    cur_dict["error_y"] = Dict(
      "type" => "data",
      "array" => kwargs[:yerr]
    )
  end

  if haskey(kwargs, :legend)
    if isa(kwargs[:legend], Bool)
      simple_plot.layout["showlegend"] = kwargs[:legend]
    else
      legend_position = kwargs[:legend]

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
  cur_color = rgba_string(_palette[cur_index])

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

  deepcopy(simple_plot)
end

function plot!(simple_plot::SimplePlot, varargs...; kwargs...)
  _plot!(simple_plot, "lines", varargs...; kwargs...)
end

function scatter!(simple_plot::SimplePlot, varargs...; kwargs...)
  _plot!(simple_plot, "markers", varargs...; kwargs...)
end

function title!(simple_plot::SimplePlot, cur_string::AbstractString)
  simple_plot.layout["title"] = cur_string
  deepcopy(simple_plot)
end

function xlabel!(simple_plot::SimplePlot, cur_string::AbstractString)
  simple_plot.layout["xaxis"]["title"] = cur_string
  deepcopy(simple_plot)
end

function ylabel!(simple_plot::SimplePlot, cur_string::AbstractString)
  simple_plot.layout["yaxis"]["title"] = cur_string
  deepcopy(simple_plot)
end

function xscale!(simple_plot::SimplePlot, cur_symbol::Symbol)
  ( cur_symbol == :log10 ) && ( cur_symbol = :log )
  simple_plot.layout["xaxis"]["exponentformat"] = "power"
  simple_plot.layout["xaxis"]["type"] = string(cur_symbol)
  deepcopy(simple_plot)
end

function yscale!(simple_plot::SimplePlot, cur_symbol::Symbol)
  ( cur_symbol == :log10 ) && ( cur_symbol = :log )

  simple_plot.layout["yaxis"]["exponentformat"] = "power"
  simple_plot.layout["yaxis"]["type"] = string(cur_symbol)
  deepcopy(simple_plot)
end

function xlims!(simple_plot::SimplePlot, varargs...)
  @assert 1 <= length(varargs) <= 2

  if length(varargs) == 1
    cur_lims = first(varargs)
    @assert isa(cur_lims, Tuple)
  else
    cur_lims = tuple(varargs...)
  end

  simple_plot.layout["xaxis"]["autorange"] = false
  simple_plot.xlims = cur_lims

  deepcopy(simple_plot)
end

function ylims!(simple_plot::SimplePlot, varargs...)
  @assert 1 <= length(varargs) <= 2

  if length(varargs) == 1
    cur_lims = first(varargs)
    @assert isa(cur_lims, Tuple)
  else
    cur_lims = tuple(varargs...)
  end

  simple_plot.layout["yaxis"]["autorange"] = false
  simple_plot.ylims = cur_lims

  deepcopy(simple_plot)
end

function xticks!(simple_plot::SimplePlot, cur_ticks)
  if !isa(cur_ticks, Tuple)
    cur_ticks = tuple(collect(cur_ticks))
  end

  simple_plot.xticks = cur_ticks
  deepcopy(simple_plot)
end

function yticks!(simple_plot::SimplePlot, cur_ticks)
  if !isa(cur_ticks, Tuple)
    cur_ticks = tuple(collect(cur_ticks))
  end

  simple_plot.yticks = cur_ticks
  deepcopy(simple_plot)
end

function annotate!(simple_plot::SimplePlot, x_position::Number, y_position::Number, cur_text::PlotText)
  cur_font = Dict()

  ( cur_text.font.family == "" ) || ( cur_font["family"] = cur_text.font.family )
  isnothing( cur_text.font.color ) || ( cur_font["color"] = rgba_string(cur_text.font.color) )
  ( cur_text.font.pointsize == -1 ) || ( cur_font["size"] = cur_text.font.pointsize )

  push!(
    simple_plot.layout["annotations"],
    Dict(
      "text" => cur_text.str,
      "textangle" => cur_text.font.rotation,
      "showarrow" => false,
      "x" => x_position,
      "y" => y_position,
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

title!(cur_string::AbstractString) = title!(_plot, cur_string)

xlabel!(cur_string::AbstractString) = xlabel!(_plot, cur_string)
ylabel!(cur_string::AbstractString) = ylabel!(_plot, cur_string)

xscale!(cur_symbol::Symbol) = xscale!(_plot, cur_symbol)
yscale!(cur_symbol::Symbol) = yscale!(_plot, cur_symbol)

xlims!(cur_lims...) = xlims!(_plot, cur_lims...)
ylims!(cur_lims...) = ylims!(_plot, cur_lims...)

xticks!(cur_ticks) = xticks!(_plot, cur_ticks)
yticks!(cur_ticks) = yticks!(_plot, cur_ticks)

plot!(varargs...; kwargs...) = plot!(_plot, varargs...; kwargs...)
scatter!(varargs...; kwargs...) = scatter!(_plot, varargs...; kwargs...)

export plot, plot!
export scatter, scatter!

export title!
export annotate!

export xlabel!
export ylabel!

export xscale!
export yscale!

export xlims!
export ylims!

export xticks!
export yticks!
