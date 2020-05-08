function make_gui_widget(cur_binding::Expr)
  if cur_binding.head == :escape && length(cur_binding.args) == 1
    cur_binding = cur_binding.args[1]
  end

  strip_escape!(cur_binding)

  @assert cur_binding.head == :(=)
  cur_symbol, cur_range = cur_binding.args

  Expr(
    :(=), esc(cur_symbol),
    Expr(
      :call, widget, esc(cur_range), Expr(
        :kw, :label, string(cur_symbol)
      )
    )
  )
end
