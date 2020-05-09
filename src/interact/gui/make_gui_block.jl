function make_gui_block(cur_block, cur_symbols)
  cur_func = gensym()

  cur_lambda = Expr(
    :(->),
    Expr(:tuple, cur_symbols...),
    cur_block
  )

  quote
    $(cur_func) = $(cur_lambda)

    cur_observer = SimplePlots.Observables.Observable{Any}(
      $(cur_func)(
        $(map(
          cur_symbol -> :( observe( $(cur_symbol) )[] ),
          cur_symbols
        )...)
      )
    )

    map!(
      $(cur_func), cur_observer, $(map(
        cur_symbol -> :( observe( $(cur_symbol) ) ),
        cur_symbols
      )...)
    )

    cur_observer
  end
end
