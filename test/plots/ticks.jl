# simple ticks tests

xticks = 2:2:8

x_ticks_1 = plot(1:9)
plot!(xticks=xticks)

x_ticks_2 = plot(1:9)
xticks!(x_ticks_2, xticks)

test_is_same_object(x_ticks_1, x_ticks_2)

# labeled ticks tests

yticks = (-1:+1, ["min", "zero", "max"])

x_range = -1:0.25:+1
y_range = x_range .^ 3

y_ticks_1 = plot(x_range, y_range, yticks=yticks)

y_ticks_2 = plot(x_range, y_range)
yticks!(yticks)

test_is_same_object(y_ticks_1, y_ticks_2)
