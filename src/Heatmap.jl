function normalizeHalfs!(M::AbstractMatrix,kx::AbstractVector,ky::AbstractVector,separationLine::Function)
    upperhalf(x,y) = y >separationLine(x)
    max1 = maximum(abs,[M[i,j] for i in eachindex(kx),j in eachindex(ky) if upperhalf(kx[i],ky[j])])
    max2 = maximum(abs,[M[i,j] for i in eachindex(kx),j in eachindex(ky) if !(upperhalf(kx[i],ky[j]))])

    for (j,y) in enumerate(ky), (i,x) in enumerate(kx)
        if upperhalf(x,y)
            M[i,j] /=max1
        else
            M[i,j] /=max2
        end
    end
    return M
end

function halfhalfheatmap!(ax,kx::AbstractVector,ky::AbstractVector,M::AbstractMatrix,separationLine::Function;heatmapfunc!::Function = heatmap!,normalize = false,kwargs...)
    normalize && normalizeHalfs!(M,kx,ky,separationLine)
    hm = heatmapfunc!(ax,kx,ky,M;kwargs...)
    lines!(ax,kx,separationLine.(kx),color = :white,linewidth = 4)
    limits!(ax,minimum(kx),maximum(kx),minimum(ky),maximum(ky))
    return hm
end

function halfhalfheatmap!(ax,kx::AbstractVector,ky::AbstractVector,F1::Function,F2::Function,separationLine::Function = x->1000x;kwargs...)
    M = CombinedMatrix(kx,ky,F1,F2,separationLine)
    halfhalfheatmap!(ax,kx,ky,M,separationLine;kwargs...)
end

function CombinedMatrix(kx::AbstractVector,ky::AbstractVector,F1::Function,F2::Function,separationLine::Function = x->1000x;normalize = false)
    function Mfunc(x,y)
        if y<= separationLine(x)
            return F1(x,y)
        end
        return F2(x,y)
    end

    M = fetch.([Threads.@spawn Mfunc(x,y) for x in kx, y in ky])
    normalize && normalizeHalfs!(M,kx,ky,separationLine)
    return M
end

function removeFromMatrix(qx::AbstractVector,qy::AbstractVector,Mat::AbstractMatrix,sep::Function)
    function mel(i,j)
        kx, ky = qx[i], qy[j]
        sep(kx,ky) && return Mat[i,j]
        return missing
    end
    return [mel(i,j) for i in eachindex(qx), j in eachindex(qy)]
end

function numberheatmap!(ax::Makie.AbstractAxis,x,y,z::AbstractMatrix;plotheatmap=true,kwargs...)
    if plotheatmap
        heatmap!(ax,x,y,z;kwargs...)
    end
    for (i,xi) in enumerate(x), (j,yj) in enumerate(y)
        color = z[i, j] < mean(z) ? :white : :black
        text!(ax,xi,yj,text = string(z[i,j]),align = (:center, :center);color)
    end
end
function numberheatmap!(ax::Makie.AbstractAxis,x,y,z::Function;kwargs...)
    zMat = [z(x,y) for x in x, y in y]
    numberheatmap!(ax,x,y,zMat;kwargs...)
end
numberheatmap!(args...;kwargs...) = numberheatmap!(current_axis(),args...;kwargs...)
function numberheatmap(args...;axis = (;),kwargs...)
    fig = Figure()
    ax = Axis(fig[1,1];axis...)
    numberheatmap!(ax,args...;kwargs...)
    fig
end
numberheatmap!(z::AbstractMatrix;kwargs...) = numberheatmap!(axes(z,1),axes(z,2),z;kwargs...)
numberheatmap(z::AbstractMatrix;kwargs...) = numberheatmap(axes(z,1),axes(z,2),z;kwargs...)
