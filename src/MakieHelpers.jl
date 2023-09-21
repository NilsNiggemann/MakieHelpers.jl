module MakieHelpers
using Makie, CairoMakie

include("Ticks.jl")

export PiTicks, SimpleTicks

include("insets.jl")
export getbboxatPoint, insetAtPoint

include("Heatmap.jl")
export normalizeHalfs!, halfhalfheatmap!, removeFromMatrix

include("Cuts3D.jl")
export surfacePlot!, surfaceCut!, surfaceSliders!, surfaceSliders

include("Themes.jl")
export theme_SimpleTicks, theme_PiTicks

using PrecompileTools
include("precompile.jl")
end # module
