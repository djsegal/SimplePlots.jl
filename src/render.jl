function render(cur_size, cur_data, cur_layout, cur_config)
  if is_repl
    render_unicode(cur_size, cur_data, cur_layout, cur_config)
  else
    render_html(cur_size, cur_data, cur_layout, cur_config)
  end
end

# render_unicode in repl.jl

function render_html(cur_size, cur_data, cur_layout, cur_config)
  cur_plot_div = "js-plot-" * string(UUIDs.uuid4())

  cur_html = """
    <div id="$(cur_plot_div)" style="width:$(cur_size[1])px;height:$(cur_size[2])px;"></div>
  """

  cur_html *= _render_html_script(
    cur_plot_div, cur_data, cur_layout, cur_config
  )

  HTML(cur_html)
end

function _render_html_script(cur_plot_div, cur_data, cur_layout, cur_config)
  """
    <script class="js-new-plot-script">
      var anonFunc = function () {
        plotDiv = document.getElementById('$(cur_plot_div)');
        if ( plotDiv === null ) { return; }

        Plotly.newPlot(
          plotDiv,
          $(JSON.json(cur_data)),
          $(JSON.json(cur_layout)),
          $(JSON.json(cur_config))
        );
      }

      customPlotLoader(anonFunc);
    </script>
  """
end
