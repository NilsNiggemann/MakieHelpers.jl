module MakieHelpers
    using Makie

    include("Ticks.jl")

    export PiTicks,SimpleTicks
    
    include("insets.jl")
    export getbboxatPoint, insetAtPoint
    
    include("Heatmap.jl")
    export normalizeHalfs!,halfhalfheatmap!,removeFromMatrix
    
    include("Cuts3D.jl")
    export surfacePlot!,surfaceCut!

end # module
