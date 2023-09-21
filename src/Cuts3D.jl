"""Plots 3D surface given by f(u,v) → [x,y,z]"""
function surfacePlot!(ax,u::AbstractArray,v::AbstractArray,f::Function,s = surface!;kwargs...)

    X1 = [f(u,v)[1] for u in u, v in v]
    Y1 = [f(u,v)[2] for u in u, v in v]
    Z1 = [f(u,v)[3] for u in u, v in v]
    
    s(ax, X1, Y1, Z1 ;kwargs...)
end

"""Plots values in funcpoints on 3D surface given by f(u,v) → [x,y,z]"""
function surfaceCut!(ax,u::AbstractArray,v::AbstractArray,surfFunc::Function,funcpoints::AbstractMatrix;kwargs...)

    surfacePlot!(ax, u,v,surfFunc; color = funcpoints,kwargs...)
end

"""Plots values of funcpoints on 3D surface given by f(u,v) → [x,y,z]"""
function surfaceCut!(ax,u::AbstractArray,v::AbstractArray,surfFunc::Function,plotfunc::Function;threads = false,kwargs...)
    funcpoints = if threads
        fetch.([Threads.@spawn plotfunc(surfFunc(qi,qj)) for qi in u, qj in v])
    else
        [plotfunc(surfFunc(qi,qj)) for qi in u, qj in v]
    end

    surfacePlot!(ax, u,v,surfFunc; color = funcpoints,kwargs...)

end

"""
    Interactive plot of 3D volume slices
    surfaceSliders(x,y,z,Func;kwargs...)
    kwargs are passed to Makie.volumeslices!
taken from https://docs.makie.org/stable/reference/plots/volumeslices/#examples"""

function surfaceSliders(x,y,z,vol;kwargs...)
    fig = Figure()
    ax = Axis3(fig[1, 1], aspect = (1,1,1))
    sgrid = SliderGrid(
        fig[2, 1],
        (label = "yz plane - x axis", range = 1:length(x)),
        (label = "xz plane - y axis", range = 1:length(y)),
        (label = "xy plane - z axis", range = 1:length(z)),
    )
    surfaceSliders!(ax,sgrid,x,y,z,vol;kwargs...)
    return fig
end

function surfaceSliders!(ax::Makie.Block,sgrid,x,y,z,vol;kwargs...)

    lo = sgrid.layout
    nc = ncols(lo)

    plt = volumeslices!(ax, x, y, z, vol;kwargs...)

    # connect sliders to `volumeslices` update methods
    sl_yz, sl_xz, sl_xy = sgrid.sliders

    on(sl_yz.value) do v; plt[:update_yz][](v) end
    on(sl_xz.value) do v; plt[:update_xz][](v) end
    on(sl_xy.value) do v; plt[:update_xy][](v) end


    set_close_to!(sl_yz, .5length(x))
    set_close_to!(sl_xz, .5length(y))
    set_close_to!(sl_xy, .5length(z))

    # add toggles to show/hide heatmaps
    # hmaps = [plt[Symbol(:heatmap_, s)][] for s ∈ (:yz, :xz, :xy)]
    # toggles = [Toggle(lo[i, nc + 1], active = true) for i ∈ 1:length(hmaps)]
    # toggle = Toggle(lo[:, nc + 1], active = true)
    # map(zip(hmaps, toggles)) do (h, t)
    #     connect!(h.visible, t.active)
    # end
    plt
end