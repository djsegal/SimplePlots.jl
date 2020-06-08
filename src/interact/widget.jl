struct Widget
  range::Vector
  index::Int
  label::AbstractString
  type::AbstractString
  datatype::DataType
end

function widget(input_range; value=nothing, label::AbstractString="", type::AbstractString="")
  isa(input_range, Widget) && return input_range
  @assert label != ""

  cur_range = collect(input_range)

  if type == ""
    if all(isa.(cur_range, Number)) && !all(isa.(cur_range, Bool))
      type = "slider"
    else
      if length(cur_range) <= 5
        type = "toggle"
      else
        type = "dropdown"
      end
    end
  end

  @assert isa(cur_range, Array)
  datatype = eltype(cur_range)

  if isnothing(value)
    if all(isa.(cur_range, Number))
      cur_index = Int(ceil( length(cur_range) // 2 ))
    else
      cur_index = 1
    end
  else
    all_indices = findall(cur_value -> cur_value == value, cur_range)

    @assert length(all_indices) == 1
    cur_index = all_indices[1]
  end

  cur_widget = Widget(cur_range, cur_index, label, type, datatype)
  observe!(cur_widget)

  cur_widget
end

get_value(cur_widget::Widget) = cur_widget.range[cur_widget.index]

slider = widget
dropdown = widget

export slider, dropdown
