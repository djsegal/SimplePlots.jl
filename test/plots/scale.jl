# log scale tests

scale_x_data = 10.0 .^ (-2:2)
scale_y_data = rand(5)

plot_1 = plot(scale_x_data, scale_y_data, title="plot 1")
yscale!(:log10)
xscale!(:log)

plot_2 = plot(
  scale_x_data, scale_y_data,
  xscale=:log10, yscale=:log
)

title!(plot_2, "plot 2")

test_is_same_object(plot_1, plot_2; except=["title"])

# lin scale tests

plot_A = plot(scale_x_data, scale_y_data, title="plot A")
xscale!(:log) ; yscale!(:linear)

plot_B = plot(
  scale_x_data, scale_y_data, xscale=:log10
)

title!("plot B")

test_is_same_object(plot_A, plot_B; except=["title"])
test_is_not_same_object(plot_A, plot_1; except=["title"])

# non-positive tests

plot(1:5, 1:5)
plot(1:5, 1:5, xscale=:log10, yscale=:log10)

plot(0:4, 1:5, xscale=:lin, yscale=:log10)
@test_throws AssertionError plot(0:4, 1:5, xscale=:log, yscale=:log10)

plot(1:5, -1:3, xscale=:log10, yscale=:identity)
@test_throws AssertionError plot(1:5, -1:3, xscale=:log10, yscale=:log10)
