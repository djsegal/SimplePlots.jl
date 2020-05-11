struct GUI
  id::UUID
  widgets::Vector{Widget}
  expression::Expr
end

macro gui(expr)
  if expr.head != :for
    error(
      "@gui syntax is @gui for ",
      " [<variable>=<domain>,]... <expression> end"
    )
  end

  is_gui = true
  quote_widgets, cur_block, cur_bindings, cur_symbols = _manipulate_outer(expr, is_gui)

  return quote
    cur_widgets = make_gui_list($(quote_widgets...))
    cur_listener = $(esc(make_gui_block(cur_block, cur_symbols)))

    cur_id = _manipulate_inner(cur_widgets, cur_listener, $(is_gui))
    nothing
  end
end

macro manipulate(expr)
  if expr.head != :for
    error(
      "@manipulate syntax is @manipulate for ",
      " [<variable>=<domain>,]... <expression> end"
    )
  end

  is_gui = false
  quote_widgets, cur_block, cur_bindings, cur_symbols = _manipulate_outer(expr, is_gui)

  return quote
    cur_widgets = make_gui_list($(quote_widgets...))
    cur_listener = $(esc(make_gui_block(cur_block, cur_symbols)))

    cur_id = _manipulate_inner(cur_widgets, cur_listener, $(is_gui))
    nothing
  end
end

export @gui, @manipulate
