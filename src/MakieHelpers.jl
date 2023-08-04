module MakieHelpers
    using Makie,CairoMakie

    include("Ticks.jl")

    export PiTicks,SimpleTicks
    
    include("insets.jl")
    export getbboxatPoint, insetAtPoint
    
    include("Heatmap.jl")
    export normalizeHalfs!,halfhalfheatmap!,removeFromMatrix
    
    include("Cuts3D.jl")
    export surfacePlot!,surfaceCut!

    using PrecompileTools
    include("precompile.jl")
end # module
