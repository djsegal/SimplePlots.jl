macro gui(expr)
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
      cur_range = Base.eval(cur_range)
    elseif isa(cur_range, Bool)
      cur_range = [cur_range, !cur_range]
    elseif isa(cur_range, Symbol)
      cur_range = Base.eval(cur_range)
    else
      @assert isa(cur_range, Widget)
    end

    cur_widget = widget(cur_range, label=string(cur_symbol))
    push!(cur_widgets, cur_widget)
  end

  cur_id = UUIDs.uuid4()

  cur_script = """
    <script>
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
          newValue = curEvent.target.innerText;
          \$(curEvent.target).closest(".cs-dropdown").children("label").text(newValue);

          tmpRange = $( json(strip.(string.(cur_widget.range))) );
          tmpIndex = tmpRange.indexOf(newValue);

          if ( tmpIndex < 0 ) { alert("Unable to find dropdown label!"); }
          tmpRange.splice(tmpIndex, 1);

          curItems = \$(curEvent.target).closest(".cs-dropdown").children("ul").children("li");

          \$.each(curItems, function(workIndex, workValue) {
            workValue.innerText = tmpRange[workIndex];
          });

          tmpSpan = \$(curEvent.target).closest(".js-widget").children(".js-widget-value")[0];
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
  """

  tmp_block = deepcopy(cur_block)
  for cur_widget in cur_widgets
    work_block = :(
      $(Symbol(cur_widget.label)) = $( cur_widget.range[ cur_widget.index ] )
    )

    insert!(tmp_block.args, 2, work_block)
  end
  eval(tmp_block)

  cur_html *= _show(_plot).content

  cur_html *= """
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
          tmpRange = $( map(string,cur_widget.range) );
          newValue = tmpRange[values[handle]];

          tmpSpan = \$(that.parentElement).children(".js-widget-value")[0];
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
    curComm = IPython.notebook.kernel.comm_manager.register_target("$(comm_id)", function (comm, msg) {
      interactComms["$(comm_id)"] = comm;

      comm.on_msg(function(msg) {
        var tmpPlot = \$("#js-interact__$( string(cur_id) ) .js-plotly-plot")[0];

        Plotly.purge(tmpPlot);
        Plotly.plot(tmpPlot, msg.content.data.plot);
      });

      comm.on_close(function(msg) { console.log("Julia close message: " + msg); });
    })
  """

  cur_script *= """
    \$("#js-interact__$( string(cur_id) )").on("interact", function() {
      var msgLabels = \$("#js-interact__$( string(cur_id) ) .cs-widget-label").map(function(){
         return \$.trim(\$(this).text());
      }).get();

      var msgValues = \$("#js-interact__$( string(cur_id) ) .cs-widget-value").map(function(){
         return \$.trim(\$(this).text());
      }).get();

      var msgDict = msgLabels.reduce((obj, k, i) => ({...obj, [k]: msgValues[i] }), {});
      interactComms["$(comm_id)"].send(msgDict);
    });
  """

  cur_script *= """
    </script>
  """

  display(HTML(cur_html * cur_script))

  cur_comm = Comm(Symbol(comm_id))

  cur_comm.on_msg = function (cur_message)
    tmp_block = deepcopy(cur_block)
    for (cur_key, cur_value) in cur_message.content["data"]
      work_block = :(
        $(Symbol(cur_key)) = $( cur_value )
      )

      insert!(tmp_block.args, 2, work_block)
    end

    eval(tmp_block)
    cur_json = custom_json(_plot)

    send_comm(cur_comm, Dict("plot" => cur_json))
  end

  return

end

export @gui
