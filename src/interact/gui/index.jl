include("make_gui_html.jl")
include("make_gui_widget.jl")
include("make_gui_expression.jl")
include("make_gui_bootloader.jl")

make_gui_list(cur_widgets::Widget...) = [cur_widgets...]

include("_gui.jl")
