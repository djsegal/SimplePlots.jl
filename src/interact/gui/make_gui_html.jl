function make_gui_html(cur_id, cur_widgets)
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

  cur_id
end
