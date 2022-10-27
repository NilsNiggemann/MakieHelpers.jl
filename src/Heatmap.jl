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
    lines!(ax,kx,separationLine.(kx),color = :white,lw = 4)
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
