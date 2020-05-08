macro _gui(expr)
  @assert expr.head == :for

  cur_block = strip_escape!(expr.args[2])
  cur_bindings = strip_escape!(expr.args[1])

  if cur_bindings.head == :block
    cur_bindings = cur_bindings.args
  else
    cur_bindings = [cur_bindings]
  end

  gui_id = UUIDs.uuid4()
  gui_widgets = map(make_gui_widget, cur_bindings)

  cur_gui = GUI(gui_id, Widget[], strip_escape!(cur_block))

  expr_post = Dict{UUID,Expr}()

  return quote

    cur_id = $(gui_id)

    cur_widgets = make_gui_list($(gui_widgets...))
    append!($(cur_gui.widgets), cur_widgets)

    make_gui_html(cur_id, cur_widgets)

    comm_observer = Observable(0)
    comm_id = "interact-$( string(cur_id) )"

    cur_watcher = on(comm_observer) do cur_value

      cur_comm = Comm(Symbol(comm_id))

      cur_comm.on_msg = function (cur_message)

        message_data = cur_message.content["data"]

        SimplePlot()

        cur_output = $(__module__).eval(
          make_gui_expression($(cur_gui), message_data)
        )

        shown_plot = isa(cur_output, SimplePlot) ? cur_output : _plot

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

    $(interact_comms)[comm_id] = comm_observer
    $(make_gui_bootloader)(Main, cur_id)

    $(cur_gui)
  end
end
