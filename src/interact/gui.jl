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

  Base.eval(__module__, :(SimplePlots.@_manipulate($(Expr(:for,esc.(expr.args)...)),true)))
  nothing
end

macro manipulate(expr)
  if expr.head != :for
    error(
      "@manipulate syntax is @manipulate for ",
      " [<variable>=<domain>,]... <expression> end"
    )
  end

  Base.eval(__module__, :(SimplePlots.@_manipulate($(Expr(:for,esc.(expr.args)...)),false)))
  nothing
end

export @gui, @manipulate
