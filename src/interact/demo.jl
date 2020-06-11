struct Demo
  expression::Expr
end

macro demo(expr)
  if expr.head != :for
    error(
      "@demo syntax is @demo for ",
      " [<variable>=<domain>,]... <expression> end"
    )
  end

  is_gui = true
  quote_widgets, cur_block, cur_bindings, cur_symbols = _manipulate_outer(expr, is_gui)

  cur_demo = Demo(cur_block)

  return quote
    cur_widgets = make_gui_list($(quote_widgets...))
    cur_listener = $(esc(make_gui_block(cur_block, cur_symbols)))

    cur_id = _manipulate_inner(cur_widgets, cur_listener, $(is_gui))
    _demo_inner(cur_id, $(cur_demo).expression, $(__module__), cur_widgets)
  end
end

function _demo_inner(cur_id, cur_expression, cur_module, cur_widgets)
  plot_tree = build_tree(
    compile_tree_dict(cur_expression, cur_widgets)
  )

  for cur_node in plot_tree.nodes
    isa(cur_node, TreeNode) && continue

    SimplePlot()
    cur_output = Base.eval(cur_module, cur_node.value)
    shown_plot = isa(cur_output, SimplePlot) ? cur_output : _plot

    cur_node.value = custom_json(shown_plot)
  end

  plot_json = tree_to_dict(plot_tree.root)

  comm_id = "interact-$( string(cur_id) )"

  display(MIME("text/javascript"), """
    demoData['""" * comm_id * """'] = $(json(plot_json))
    \$("#js-interact__$( string(cur_id) )").trigger("interact");
  """)

  nothing
end

function compile_tree_dict(cur_block, cur_widgets, cur_dict=OrderedDict())
  if isempty(cur_widgets)
    return cur_block
  end

  tmp_widgets = deepcopy(cur_widgets)
  tmp_widget = popfirst!(tmp_widgets)

  cur_symbol = Symbol(tmp_widget.label)
  cur_range = tmp_widget.range

  sub_dict = OrderedDict()

  for cur_value in cur_range
    tmp_block = deepcopy(cur_block)
    parsed_value = cur_value

    if tmp_widget.datatype == Symbol
      work_block = :(
        $(cur_symbol) = Symbol($(string(parsed_value)))
      )
    else
      work_block = :(
        $(cur_symbol) = $( parsed_value )
      )
    end

    insert!(tmp_block.args, 2, work_block)
    sub_dict[cur_value] = compile_tree_dict(tmp_block, tmp_widgets, cur_dict)
  end

  return sub_dict
end

export @demo
