function make_gui_bootloader(cur_module::Module, cur_id::UUID)
  comm_id = "interact-$( string(cur_id) )"

  display(MIME("text/javascript"), """

    var _guiBootup = function (curCallback) {
      Jupyter.notebook.kernel.comm_manager.unregister_target("$(comm_id)")
      Jupyter.notebook.kernel.comm_manager.register_target("$(comm_id)", function (comm, msg) {
        globalComms["$(comm_id)"] = comm;

        comm.on_msg(function(msg) {
          if ( "json" in msg.content.data ) {
            var workPlot = \$("#js-interact__$( string(cur_id) ) .js-plotly-plot")[0];
            if ( typeof workPlot === "undefined" ) { alert("Could not find plotly plot!"); }

            var workJson = msg.content.data.json.plot;
            customPlotlyReact(workPlot, workJson.data, workJson.layout, workJson.config);

            \$("#js-interact__$( string(cur_id) ) .js-new-plot-script").replaceWith(msg.content.data.json.script);
          } else {
            if ( "html" in msg.content.data ) {
              var tmpDisplay = \$("#js-interact__$( string(cur_id) ) .js-display");
              tmpDisplay.html(msg.content.data.html);
            } else {
              if ( "text" in msg.content.data ) {
                console.log(msg.content.data.text);
              } else {
                alert("Unrecognized interact content type!");
              }
            }
          }
        });

        comm.on_close(function(msg) { console.log("Julia close message: " + msg); });
        \$("#js-interact__$( string(cur_id) )").trigger("interact");
      })

      var curCommand = '$(string(cur_module)).SimplePlots.interact_comms["$(comm_id)"][] += 10';
      Jupyter.notebook.kernel.execute(curCommand, {"iopub": {"output": function(tmpMessage) {
        console.log(tmpMessage)
      }}});

      if ( typeof curCallback !== "undefined" ) { curCallback(); }
    }

    if ( typeof Jupyter === "undefined" ) {
      customPlotLoader(function() {
        \$("#js-interact__$( string(cur_id) )").trigger("interact");
      });
    } else {
      if (Jupyter.notebook.kernel) {
        _guiBootup()
      } else {
        Jupyter.notebook.events.one('kernel_ready.Kernel', (e) => {
          _guiBootup(function() {
            customPlotLoader(function() {
              \$("#js-interact__$( string(cur_id) )").trigger("interact");
            });
          });
        });
      }
    }
  """)
end
