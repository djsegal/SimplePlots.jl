macro demo(expr)
  demo_gui = Base.eval(__module__, :(SimplePlots.@_manipulate($(Expr(:for,esc.(expr.args)...)),true)))

  quote
    cur_gui = $(demo_gui)

    plot_tree = build_tree(
      compile_tree_dict(cur_gui.expression, cur_gui.widgets)
    )

    for cur_node in plot_tree.nodes
      isa(cur_node, TreeNode) && continue

      SimplePlot()
      cur_output = Base.eval($(__module__), cur_node.value)
      shown_plot = isa(cur_output, SimplePlot) ? cur_output : _plot

      cur_node.value = custom_json(shown_plot)
    end

    plot_json = tree_to_dict(plot_tree.root)

    comm_id = "interact-$( string(cur_gui.id) )"

    display(MIME("text/javascript"), """
      demoData['""" * comm_id * """'] = $(json(plot_json))
      \$("#js-interact__$( string(cur_gui.id) )").trigger("interact");
    """)

    nothing
  end
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

    work_block = :(
      $(cur_symbol) = $( parsed_value )
    )

    insert!(tmp_block.args, 2, work_block)
    sub_dict[cur_value] = compile_tree_dict(tmp_block, tmp_widgets, cur_dict)
  end

  return sub_dict
end

export @demo
