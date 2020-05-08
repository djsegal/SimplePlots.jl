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

  Base.eval(__module__, :(SimplePlots.@_gui($(Expr(:for,esc.(expr.args)...)))))
  nothing
end

var"@manipulate" = var"@gui"

export @gui, @manipulate
