const plotly_version = "1.53.0"

function __init__()
  is_ijulia = isdefined(Main, :IJulia) && Main.IJulia.inited
  is_juno = isdefined(Main, :Juno) && Main.Juno.isactive()
  is_vscode = isdefined(Main, :_vscodeserver)

  is_ide = is_ijulia || is_juno || is_vscode
  global is_repl = !is_ide

  global _plot = SimplePlot()
  global _palette = palette(:default)

  if is_repl
    @assert !is_repl
  else
    _init_plotly()
  end
end

function _init_plotly()
  plotly_url = "https://cdn.plot.ly/plotly-"
  plotly_url *= "$(plotly_version).min"

  plotly_javascript = """
    <script type="text/javascript" class="js-plotly-script">
      function customBootPlotly(curCallback) {
        if ( typeof Plotly !== "undefined" ) {
          if ( typeof curCallback !== "undefined" ) {
            curCallback();
          }
          return;
        }

        var plotlyScripts = document.getElementsByClassName("js-plotly-script");

        for (var i = 0; i < plotlyScripts.length; i++) {
          var scriptParent = plotlyScripts[i].parentElement;
          scriptParent.style.margin = "0";
          scriptParent.style.padding = "0";
        }

        require.config({
          paths: { Plotly: "$(plotly_url)" }
        });

        require(["Plotly"], function(Plotly){
          window.Plotly = Plotly;
          if ( typeof curCallback !== "undefined" ) {
            curCallback();
          }
        });
      }

      customBootPlotly();
    </script>
  """

  display(HTML(plotly_javascript))
end
