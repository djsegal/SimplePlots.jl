include("make_gui_html.jl")
include("make_gui_block.jl")
include("make_gui_widget.jl")
include("make_gui_bootloader.jl")

make_gui_list(cur_widgets::Widget...) = [cur_widgets...]

include("_manipulate.jl")
