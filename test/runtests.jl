using SimplePlots
using Test

include("utils/index.jl")

@testset "SimplePlots.jl" begin

  include("plots/index.jl")
  include("interact.jl")

end
