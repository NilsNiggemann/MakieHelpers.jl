function errlines!(ax::Makie.AbstractAxis,x,y,err;bandkwargs = (;),markersize=0,kwargs...)
    l = scatterlines!(ax,x,y;markersize,kwargs...)
    if markersize != 0
        errorbars!(ax,x,y,err,whiskerwidth = 3.5,color = l.color[];kwargs...)
    end
    band!(ax,x,y .- err,y .+ err;color = (l.color[],0.3),bandkwargs...)
end
errlines!(x,y,err;bandkwargs = (;),kwargs...) = errlines!(current_axis(),x,y,err;bandkwargs,kwargs...)
errlines!(y,err;bandkwargs = (;),kwargs...) = errlines!(current_axis(),eachindex(y),y,err;bandkwargs,kwargs...)
errlines!(ax::Makie.AbstractAxis,y,err;bandkwargs = (;),kwargs...) = errlines!(ax,eachindex(y),y,err;bandkwargs,kwargs...)
function errlines(args...;axis = (;),kwargs...)
    fig = Figure()
    ax = Axis(fig[1,1];axis...)
    errlines!(ax,args...;kwargs...)
    fig
end