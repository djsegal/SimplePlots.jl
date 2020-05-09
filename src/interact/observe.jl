global widget_observers = Dict{Widget, Observable}()

observe(cur_widget::Widget) = widget_observers[cur_widget]

function observe!(cur_widget::Widget, cur_observer::Observable)
  widget_observers[cur_widget] = cur_observer
end

function observe!(cur_widget::Widget, cur_value::Any)
  ( observe(cur_widget)[] == cur_value ) && return
  observe(cur_widget)[] = cur_value
end

function observe!(cur_widget::Widget)
  cur_observer = Observable{cur_widget.datatype}(get_value(cur_widget))
  observe!(cur_widget, cur_observer)
end

export observe
