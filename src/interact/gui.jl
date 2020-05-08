struct GUI
  id::UUID
  widgets::Vector{Widget}
  expression::Expr
end

macro gui(expr)
  quote
    @_gui $(expr)
    nothing
  end
end

macro _gui(expr)
  if expr.head != :for
    error(
      "@gui syntax is @gui for ",
      " [<variable>=<domain>,]... <expression> end"
    )
  end

  cur_block = expr.args[2]

  if expr.args[1].head == :block
    cur_bindings = expr.args[1].args
  else
    cur_bindings = [expr.args[1]]
  end

  cur_widgets = []

  for cur_binding in cur_bindings
    @assert cur_binding.head == :(=)
    cur_symbol, cur_range = cur_binding.args

    if isa(cur_range, Expr)
      cur_range = @eval $(cur_range)
    elseif isa(cur_range, Bool)
      cur_range = [cur_range, !cur_range]
    elseif isa(cur_range, Symbol)
      cur_range = @eval $(cur_range)
    else
      @assert isa(cur_range, Widget)
    end

    cur_widget = widget(cur_range, label=string(cur_symbol))
    push!(cur_widgets, cur_widget)
  end

  cur_id = UUIDs.uuid4()

  cur_script = """
    <script>
      var anonFunc = function () {
  """

  cur_html = """
    <div class='js-interact' id='js-interact__$( string(cur_id) )'>
      <div class='js-widgets'>
  """

  for cur_widget in cur_widgets
    cur_dict = JSON.parse(json(cur_widget))

    cur_html *= """
      <div class='cs-widget js-widget'>
        <div class='cs-widget-label'>
          $( cur_dict["label"] )
        </div>
    """

    if cur_dict["type"] == "slider"
      cur_html *= "<div class='cs-widget-slider js-widget-slider'></div>"
    elseif cur_dict["type"] == "toggle"
      cur_html *= """
        <div class='js-widget-toggle'>
          <div class="cs-button-group" style="display: inline-flex;">
      """

      for (cur_index, cur_value) in enumerate(cur_dict["range"])
        button_class = "cs-button"
        ( cur_index == cur_dict["index"] ) && ( button_class *= " cs-active" )
        ( cur_index == cur_dict["index"] - 1 ) && ( button_class *= " cs-pre-active" )

        cur_html *= """
          <div class="$(button_class)">
            $(cur_value)
          </div>
        """
      end

      cur_html *= """
          </div>
        </div>
      """
    else
      @assert cur_dict["type"] == "dropdown"

      work_id = "js-dropdown__$( UUIDs.uuid4() )"

      cur_html *= """
        <div class='js-widget-dropdown'>
          <div class="cs-dropdown-container">
            <div class="cs-dropdown">
              <input id="$(work_id)" type="checkbox">
              <label for="$(work_id)">$( cur_dict["range"][ cur_dict["index"] ] )</label>
              <ul style="margin: 0; padding: 0;">
        """

        for (cur_index, cur_value) in enumerate(cur_dict["range"])
          ( cur_index == cur_dict["index"] ) && continue
          cur_html *= "<li>$(cur_value)</li>"
        end

        cur_html *= """
              </ul>
            </div>
          </div>
        </div>
      """

      cur_script *= """
        \$(document).click(function(e) {
          if ( \$("#$(work_id):checked").length > 0 ) {
            var isAlreadyClicking = (
              ( e.target.nodeName.toLowerCase() === "label" && e.target.getAttribute("for") == "$(work_id)" ) ||
              ( e.target.nodeName.toLowerCase() === "input" && e.target.getAttribute("id") == "$(work_id)" )
            )

            if ( !isAlreadyClicking ) { \$("label[for=$work_id]").click(); }
          }
        });

        \$("#$(work_id)").parent().children("ul").children("li").click(function (curEvent) {
          var newValue = curEvent.target.innerText;
          \$(curEvent.target).closest(".cs-dropdown").children("label").text(newValue);

          var tmpRange = $( json(strip.(string.(cur_widget.range))) );
          var tmpIndex = tmpRange.indexOf(newValue);

          if ( tmpIndex < 0 ) { alert("Unable to find dropdown label!"); }
          tmpRange.splice(tmpIndex, 1);

          var curItems = \$(curEvent.target).closest(".cs-dropdown").children("ul").children("li");

          \$.each(curItems, function(workIndex, workValue) {
            workValue.innerText = tmpRange[workIndex];
          });

          var tmpSpan = \$(curEvent.target).closest(".js-widget").children(".js-widget-value")[0];
          tmpSpan.innerText = newValue;

          \$("#js-interact__$( string(cur_id) )").trigger("interact");
        })

      """
    end

    cur_html *= """
      <div class='cs-widget-value js-widget-value $( cur_dict["type"] == "slider" ? "" : "cs-hidden" )'>
        $( cur_dict["range"][ cur_dict["index"] ] )
      </div>

      </div>
    """
  end

  cur_html *= """
      </div>

      <div class='js-display'>
      </div>
    </div>
  """

  for cur_widget in cur_widgets
    ( cur_widget.type == "slider" ) || continue

    cur_script *= """
      var foundSlider = false;
      \$("#js-interact__$( string(cur_id) ) .js-widget-slider").each(function( index ) {
        var tmpText = \$(this.parentElement).children(".cs-widget-label").text().trim();
        if ( tmpText !== "$( cur_widget.label )" ) { return; }

        if ( foundSlider ) { alert("There are repeated sliders!"); }

        foundSlider = true;
        noUiSlider.create(this, {
            start: $( cur_widget.index - 1 ),
            step: 1,
            connect: "lower",
            format: wNumb({
              decimals: 0
            }),
            range: {
              min: 0,
              max: $( length(cur_widget.range) - 1 )
            }
        });

        var that = this;
        this.noUiSlider.on('update', function (values, handle) {
          var tmpRange = $( map(string,cur_widget.range) );
          var newValue = tmpRange[values[handle]];

          var tmpSpan = \$(that.parentElement).children(".js-widget-value")[0];
          tmpSpan.innerText = newValue;

          \$("#js-interact__$( string(cur_id) )").trigger("interact");
        });
      });
      if ( !foundSlider ) { alert("Unable to find all sliders!"); }
    """
  end

  cur_script *= """
    \$(".js-widget-toggle .cs-button").click(function (curEvent) {
      if ( !\$(curEvent.target).hasClass("cs-active") ) {
        var curItems = \$(curEvent.target.parentElement).children(".cs-button");
        var curIndex = curItems.index(curEvent.target);

        \$.each(curItems, function(workIndex, workValue) {
          var otherTarget = \$(curEvent.target.parentElement.children[workIndex]);

          otherTarget.removeClass("cs-active");
          otherTarget.removeClass("cs-pre-active");

          if ( workIndex == curIndex ) { otherTarget.addClass("cs-active"); }
          if ( workIndex == curIndex - 1 ) { otherTarget.addClass("cs-pre-active"); }
        });

        var curWidgetVal = \$(curEvent.target).closest(".js-widget").children(".js-widget-value")[0];
        curWidgetVal.innerText = curEvent.target.innerText;

        \$("#js-interact__$( string(cur_id) )").trigger("interact");
      }
    });
  """

  comm_id = "interact-$( string(cur_id) )"

  cur_script *= """
    \$("#js-interact__$( string(cur_id) )").on("interact", function() {
      var msgLabels = \$("#js-interact__$( string(cur_id) ) .cs-widget-label").map(function(){
         return \$.trim(\$(this).text());
      }).get();

      var msgValues = \$("#js-interact__$( string(cur_id) ) .cs-widget-value").map(function(){
         return \$.trim(\$(this).text());
      }).get();

      var msgDict = msgLabels.reduce((obj, k, i) => ({...obj, [k]: msgValues[i] }), {});

      var workPlotlyId = \$("#js-interact__$( string(cur_id) ) .js-plotly-plot").attr("id");
      msgDict["___interact_plot_id___"] = workPlotlyId;

      if ( "$(comm_id)" in demoData ) {
        tmpData = demoData["$(comm_id)"];
  """

  for cur_widget in cur_widgets
    cur_script *= """
      tmpData = tmpData[msgDict["$(cur_widget.label)"]];
    """
  end

  cur_script *= """
        var workPlot = \$("#js-interact__$( string(cur_id) ) .js-plotly-plot")[0];
        var workJson = tmpData;

        if ( typeof workPlot === "undefined" ) {
          var tmpDisplay = \$("#js-interact__$( string(cur_id) ) .js-display");
          var tmpPlotId = "$("js-plot-" * string(UUIDs.uuid4()))";
          tmpDisplay.html('<div id="' + tmpPlotId + '" style="width:$(default_plot_size[1])px;height:$(default_plot_size[2])px;"></div>');

          plotDiv = document.getElementById(tmpPlotId);
          Plotly.newPlot(plotDiv, workJson.data, workJson.layout, workJson.config);
        } else {
          customPlotlyReact(workPlot, workJson.data, workJson.layout, workJson.config);
        }
      } else {
        if ( "$(comm_id)" in globalComms ) {
          globalComms["$(comm_id)"].send(msgDict);
        } else {
          console.log("Unable to startup GUI – may be waiting for demo data...")
        }
      }
    });
  """

  cur_script *= """
      }

      customPlotLoader(anonFunc);
    </script>
  """

  display(HTML(cur_html * cur_script))

  cur_anon_func = function (cur_comm::Comm, cur_message, cur_module::Module)

    tmp_block = deepcopy(cur_block)

    for (cur_key, cur_value) in cur_message.content["data"]
      ( cur_key == "___interact_plot_id___" ) && continue

      cur_widget = cur_widgets[findfirst(tmp_widget -> tmp_widget.label == cur_key, cur_widgets)]

      if cur_widget.datatype <: AbstractString
        parsed_value = cur_value
      else
        parsed_value = parse(cur_widget.datatype, cur_value)
      end

      work_block = :(
        $(Symbol(cur_key)) = $( parsed_value )
      )

      insert!(tmp_block.args, 2, work_block)
    end

    SimplePlot()

    cur_output = Base.eval(cur_module, tmp_block)
    shown_plot = isa(cur_output, SimplePlot) ? cur_output : _plot

    if "___interact_plot_id___" in keys(cur_message.content["data"])
      plot_json = custom_json(shown_plot)
      cur_size, cur_data, cur_layout, cur_config = _show_helper(shown_plot)

      # cur_size is currently unused in update call

      plot_script = _render_html_script(
        cur_message.content["data"]["___interact_plot_id___"], cur_data, cur_layout, cur_config
      )

      send_comm(cur_comm, Dict("json" => Dict("plot" => plot_json, "script" => plot_script)))
    else
      plot_html = _show(shown_plot).content
      send_comm(cur_comm, Dict("html" => plot_html))
    end

  end

  cur_gui = GUI(cur_id, cur_widgets, cur_block)

  return quote
    comm_observer = Observable(0)

    cur_watcher = on(comm_observer) do cur_value
      cur_comm = Comm(Symbol($(comm_id)))

      cur_comm.on_msg = function (cur_message)
        $(cur_anon_func)(cur_comm, cur_message, @__MODULE__)
      end
    end

    $(interact_comms)[$(comm_id)] = comm_observer

    display(MIME("text/javascript"), """

      var _guiBootup = function (curCallback) {
        Jupyter.notebook.kernel.comm_manager.unregister_target("$($(comm_id))")
        Jupyter.notebook.kernel.comm_manager.register_target("$($(comm_id))", function (comm, msg) {
          globalComms["$($(comm_id))"] = comm;

          comm.on_msg(function(msg) {
            if ( "json" in msg.content.data ) {
              var workPlot = \$("#js-interact__$( string($(cur_id)) ) .js-plotly-plot")[0];
              if ( typeof workPlot === "undefined" ) { alert("Could not find plotly plot!"); }

              var workJson = msg.content.data.json.plot;
              customPlotlyReact(workPlot, workJson.data, workJson.layout, workJson.config);

              \$("#js-interact__$( string($(cur_id)) ) .js-new-plot-script").replaceWith(msg.content.data.json.script);
            } else {
              if ( "html" in msg.content.data ) {
                var tmpDisplay = \$("#js-interact__$( string($(cur_id)) ) .js-display");
                tmpDisplay.html(msg.content.data.html);
              } else {
                alert("Unrecognized interact content type!");
              }
            }
          });

          comm.on_close(function(msg) { console.log("Julia close message: " + msg); });
          \$("#js-interact__$( string($(cur_id)) )").trigger("interact");
        })

        Jupyter.notebook.kernel.execute('$(string(@__MODULE__)).SimplePlots.interact_comms["$($(comm_id))"][] += 1')
        if ( typeof curCallback !== "undefined" ) { curCallback(); }
      }

      if ( typeof Jupyter === "undefined" ) {
        customPlotLoader(function() {
          \$("#js-interact__$( string($(cur_id)) )").trigger("interact");
        });
      } else {
        if (Jupyter.notebook.kernel) {
          _guiBootup()
        } else {
          Jupyter.notebook.events.one('kernel_ready.Kernel', (e) => {
            _guiBootup(function() {
              customPlotLoader(function() {
                \$("#js-interact__$( string($(cur_id)) )").trigger("interact");
              });
            });
          });
        }
      }

    """)

    $(cur_gui)
  end

end

@eval const $(Symbol("@manipulate")) = $(Symbol("@gui"))

export @gui, @manipulate
