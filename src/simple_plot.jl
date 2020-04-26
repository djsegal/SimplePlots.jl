import Base: show, empty!

mutable struct SimplePlot
  index::Int
  size::Tuple
  data::Vector{AbstractDict}
  layout::AbstractDict
  config::AbstractDict
  xlims::Tuple
  ylims::Tuple
  xticks::Tuple
  yticks::Tuple
end

function SimplePlot(plot_size=(600, 400))
  empty!(
    SimplePlot(
      0, plot_size, [],
      Dict(), Dict(),
      (), (), (), ()
    )
  )
end

function empty!(simple_plot::SimplePlot)
  simple_plot.index = 0

  empty!(simple_plot.data)
  empty!(simple_plot.layout)
  empty!(simple_plot.config)

  simple_plot.config["responsive"] = true

  simple_plot.layout["xaxis"] = Dict()
  simple_plot.layout["yaxis"] = Dict()

  simple_plot.layout["legend"] = Dict()

  simple_plot.layout["annotations"] = Vector{AbstractDict}()
  simple_plot.layout["showlegend"] = true

  simple_plot.layout["xaxis"]["autorange"] = true
  simple_plot.layout["yaxis"]["autorange"] = true

  simple_plot.layout["xaxis"]["type"] = "linear"
  simple_plot.layout["yaxis"]["type"] = "linear"

  simple_plot.layout["shapes"] = []

  simple_plot
end

function show(io::IO, simple_plot::SimplePlot)
  @assert false
end

function show(io::IO, m::MIME"text/plain", simple_plot::SimplePlot)
  cur_plot_id = string(UUIDs.uuid4())
  cur_plot_div = "js-plot-" * string(cur_plot_id)

  cur_layout = parse_layout(simple_plot)

  display(HTML(
    """
      <div id="$(cur_plot_div)" style="width:$(simple_plot.size[1])px;height:$(simple_plot.size[2])px;"></div>

      <script>
        var anonFunc = function () {
          plotDiv = document.getElementById('$(cur_plot_div)');
          if ( plotDiv === null ) { return; }

          Plotly.newPlot(
            plotDiv,
            $(JSON.json(simple_plot.data)),
            $(JSON.json(cur_layout)),
            $(JSON.json(simple_plot.config))
          );
        }

        customBootPlotly(anonFunc);
      </script>
    """
  ))
end
