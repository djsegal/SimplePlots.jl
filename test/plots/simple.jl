# default plot test

init_plot = plot!()
test_plot = plot()

@test isa(init_plot, SimplePlots.SimplePlot)
@test isa(test_plot, SimplePlots.SimplePlot)

test_is_same_object(init_plot, test_plot)

# lines and scatter test

plot_1 = plot(rand(10))
@test plot_1.index == 1

plot_2 = scatter!(3:7, 10.0 .^ (-2:+2))
@test plot_2.index == 2

test_is_same_object(plot_1, plot_2)
