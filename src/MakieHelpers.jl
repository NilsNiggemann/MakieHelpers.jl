module MakieHelpers
    using Makie

    include("insets.jl")
    export getbboxatPoint, insetAtPoint
    
    include("Heatmap.jl")
    export normalizeHalfs!,halfhalfheatmap!
    
    include("Cuts3D.jl")
    export surfacePlot!,surfaceCut!
end # module
