function strip_escape!(cur_expr::Expr)
  ( cur_expr.head == :escape ) || return cur_expr
  ( length(cur_expr.args) == 1 ) || return cur_expr

  first_expr = first(cur_expr.args)

  cur_expr.head = first_expr.head
  cur_expr.args = first_expr.args

  cur_expr
end
