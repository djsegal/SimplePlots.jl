function make_gui_expression(cur_gui::GUI, message_data)
  tmp_block = deepcopy(cur_gui.expression)

  cur_widgets = cur_gui.widgets
  for (cur_key, cur_value) in message_data
    ( cur_key == "___interact_plot_id___" ) && continue

    cur_widget = cur_widgets[findfirst(tmp_widget -> tmp_widget.label == cur_key, cur_widgets)]

    if cur_widget.datatype <: AbstractString
      parsed_value = cur_value
    else
      parsed_value = parse(cur_widget.datatype, cur_value)
    end

    work_block = Expr(:(=), Symbol(cur_key), parsed_value)

    insert!(tmp_block.args, 2, work_block)
  end

  tmp_block
end
