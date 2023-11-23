
@setup_workload begin
    using CairoMakie
    @compile_workload begin
        func(x,y,z) = exp(1/(x+y+z))
        kx = LinRange(0,1,10)
        ky = LinRange(0,1,5)
        func_k = fetch.([Threads.@spawn func(ki,ki,kj) for ki in kx, kj in ky])

        fig = Figure(size = (800, 600))

        ax = Axis(fig[1, 1],aspect = 1)

        lines!(ax,ky,func_k[1,:],color = :red,label = "test")
        lines!(ax,1:10,1:10,color = :blue)
        scatter!(ax,ky,func_k[1,:],color = :green,marker = :circle,markersize = 10,label = L"a_1")
        scatterlines!(ax,ky,func_k[1,:],color = :green,marker = '×',markersize = 10,label = L"test $α_1$")

        ax2 = Axis(fig[2, 1],aspect = 1,xticks = PiTicks(),yticks = SimpleTicks([1,2,3]),title = "test",xlabel = "T", ylabel = "α")
        ax3 = Axis(fig[3, 1],aspect = 1,xticks = PiTicks(-8pi:4pi:8pi),yticks = SimpleTicks(),title = "test",xlabel = L"T", ylabel = L"α")
    
        hm = heatmap!(ax3,kx,ky,func_k)
        
        axislegend(ax)
        Colorbar(fig[1, 2], hm, label = L"β")
    end
end