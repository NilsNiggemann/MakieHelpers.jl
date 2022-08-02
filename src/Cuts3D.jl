"""Plots 3D surface given by f(u,v) → [x,y,z]"""
function surfacePlot!(ax,u::AbstractArray,v::AbstractArray,f::Function;kwargs...)

    X1 = [f(u,v)[1] for u in u, v in v]
    Y1 = [f(u,v)[2] for u in u, v in v]
    Z1 = [f(u,v)[3] for u in u, v in v]
    
    surface!(ax, X1, Y1, Z1 ;kwargs...)
end

"""Plots values in funcpoints on 3D surface given by f(u,v) → [x,y,z]"""
function surfaceCut!(ax,u::AbstractArray,v::AbstractArray,surfFunc::Function,funcpoints::AbstractMatrix;kwargs...)

    surfacePlot!(ax, u,v,surfFunc; color = funcpoints,kwargs...)
end

"""Plots values of funcpoints on 3D surface given by f(u,v) → [x,y,z]"""
function surfaceCut!(ax,u::AbstractArray,v::AbstractArray,surfFunc::Function,plotfunc::Function;threads = false,kwargs...)
    funcpoints = if threads
        fetch.([Threads.@spawn Chifunc(zzerocut(qi,qj)) for qi in u, qj in v])
    else
        [Chifunc(zzerocut(qi,qj)) for qi in u, qj in v]
    end

    surfacePlot!(ax, u,v,surfFunc; color = funcpoints,kwargs...)

end