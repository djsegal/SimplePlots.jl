p1 = plot(title="Title 1")
@test p1.layout["title"] == "Title 1"

p2 = title!(plot(), "Title 2")
@test p2.layout["title"] == "Title 2"

p3 = plot()
title!("Title 3")
@test p3.layout["title"] == "Title 3"

p4 = plot(xlabel="var x")
@test p4.layout["xaxis"]["title"] == "var x"

p5 = plot()
p6 = ylabel!("var y")

test_is_same_object(p5, p6)
@test p5.layout["yaxis"]["title"] == "var y"
