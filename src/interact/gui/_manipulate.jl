function _manipulate_outer(expr, is_gui)
  @assert expr.head == :for

  cur_block = strip_escape!(expr.args[2])
  cur_bindings = strip_escape!(expr.args[1])

  is_gui && insert!(
    cur_block.args, 2, :( SimplePlots.SimplePlot() )
  )

  if cur_bindings.head == :block
    cur_bindings = cur_bindings.args
  else
    cur_bindings = [cur_bindings]
  end

  cur_symbols = map(x -> first(x.args), cur_bindings)

  gui_id = UUIDs.uuid4()
  quote_widgets = map(make_gui_widget, cur_bindings)

  return quote_widgets, cur_block, cur_bindings, cur_symbols
end

function _manipulate_inner(cur_widgets, cur_listener, is_gui)
  cur_id = UUIDs.uuid4()

  make_gui_html(cur_id, cur_widgets)

  comm_observer = Observable(0)
  comm_id = "interact-$( string(cur_id) )"

  parent_message = IJulia.execute_msg

  cur_watcher = on(comm_observer) do cur_value

    IJulia.set_cur_msg(parent_message)

    cur_comm = Comm(Symbol(comm_id))

    cur_comm.on_msg = function (cur_message)

      message_data = cur_message.content["data"]

      for (cur_key, cur_value) in message_data
        ( cur_key == "___interact_plot_id___" ) && continue

        cur_widget = cur_widgets[findfirst(tmp_widget -> tmp_widget.label == cur_key, cur_widgets)]

        if cur_widget.datatype <: AbstractString
          parsed_value = cur_value
        elseif cur_widget.datatype == Char
          if isa(cur_value, Char)
            parsed_value = cur_value
          else
            @assert isa(cur_value, AbstractString)
            @assert length(cur_value) == 1
            parsed_value = cur_value[1]
          end
        else
          parsed_value = parse(cur_widget.datatype, cur_value)
        end

        observe!(cur_widget, parsed_value)
      end

      if isa(cur_listener[], AbstractPlot)
        shown_plot = cur_listener[]
      else
        is_gui || return
        shown_plot = _plot
      end

      if "___interact_plot_id___" in keys(message_data)
        plot_json = custom_json(shown_plot)
        cur_size, cur_data, cur_layout, cur_config = _show_helper(shown_plot)

        # cur_size is currently unused in update call

        plot_script = _render_html_script(
          message_data["___interact_plot_id___"], cur_data, cur_layout, cur_config
        )

        send_comm(cur_comm, Dict("json" => Dict("plot" => plot_json, "script" => plot_script)))
      else
        plot_html = _show(shown_plot).content
        send_comm(cur_comm, Dict("html" => plot_html))
      end

    end

  end

  interact_comms[comm_id] = comm_observer
  make_gui_bootloader(Main, cur_id)

  cur_id
end
