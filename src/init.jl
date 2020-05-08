const plotly_version = "1.53.0"

function __init__()
  is_ijulia = isdefined(Main, :IJulia) && Main.IJulia.inited
  is_juno = isdefined(Main, :Juno) && Main.Juno.isactive()
  is_vscode = isdefined(Main, :_vscodeserver)

  is_ide = is_ijulia || is_juno || is_vscode
  global is_repl = !is_ide

  if is_repl
    work_size = (62, 16)

    work_palette = [
      "green", "blue", "red",
      "yellow", "cyan", "magenta"
    ]
  else
    work_size = (600, 400)

    work_palette = [
      "#636EFA", "#EF553B", "#00CC96", "#AB63FA", "#FFA15A",
      "#19D3F3", "#FF6692", "#B6E880", "#FF97FF", "#FECB52"
    ]
  end

  global _palette = work_palette
  global default_plot_size = work_size

  global interact_comms = Dict{AbstractString, Observable}()

  SimplePlot() # sets global _plots variable

  if is_repl
    include(joinpath(@__DIR__, "repl.jl"))
  else
    _init_notebook()
  end
end

function _init_notebook()
  assets_url = "https://cdn.jsdelivr.net/gh/djsegal/SimplePlots.jl/dist/"

  plotly_url = "https://cdn.plot.ly/plotly-"
  plotly_url *= "$(plotly_version).min"

  plotly_javascript = """
    <script type="text/javascript" class="js-plotly-script">
      globalComms = {};
      demoData = {};

      \$(".js-plotly-script").parent().css('padding', 0);

      function customPlotlyReact(curPlot, curData, curLayout, curConfig) {
        for (var i = 0; i < curData.length; i++) {
          curData[i]["visible"] = true;
          for (var j = 0; j < curPlot.data.length; j++) {
            if ( curData[i].name !== curPlot.data[j].name ) { continue; }
            if ( curPlot.data[j].visible !== "legendonly" ) { continue; }

            curData[i]["visible"] = "legendonly";
          }
        }

        Plotly.react(curPlot, curData, curLayout, curConfig);
      }

      function customPlotLoader(curCallback) {
        if ( \$(".js-nouislider-css").length == 0 ) {
          \$("head").append(
            '<link class="js-nouislider-css" href="$( assets_url * "nouislider.min.css" )" rel="stylesheet">'
          );
        }

        if ( \$(".js-custom-css").length == 0 ) {
          \$("head").append(
            '<link class="js-custom-css" href="$( assets_url * "custom.min.css" )" rel="stylesheet">'
          );
        }

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
          paths: {
            Plotly: "$( plotly_url )",
            noUiSlider: "$( assets_url * "nouislider.min" )",
            wNumb: "$( assets_url * "wnumb.min" )"
          }
        });

        require(["Plotly", "noUiSlider", "wNumb"], function(Plotly, noUiSlider, wNumb){
          window.Plotly = Plotly;
          window.noUiSlider = noUiSlider;
          window.wNumb = wNumb;

          if ( typeof curCallback !== "undefined" ) {
            curCallback();
          }

          \$("head").append(\$(".js-plotly-script"));
          \$("head .js-plotly-script:not(:first)").remove();
          \$("body .js-plotly-script").remove();
        });
      }

      \$(document).ready(customPlotLoader);
      customPlotLoader();
    </script>
  """

  display(HTML(plotly_javascript))

end
