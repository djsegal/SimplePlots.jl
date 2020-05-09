function validate!(cur_plot::SimplePlot)
  if cur_plot.layout["xaxis"]["type"] == "log"
    for cur_data in cur_plot.data
      @assert all( cur_data["x"] .> 0 )
    end
  end

  if cur_plot.layout["yaxis"]["type"] == "log"
    for cur_data in cur_plot.data
      @assert all( cur_data["y"] .> 0 )
    end
  end

  cur_plot
end
