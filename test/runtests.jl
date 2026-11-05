using Test, CairoMakie, MakieHelpers

function tick_labels(theme)
	with_theme(theme) do
		fig = Figure()
		ax = Axis(fig[1, 1]; limits = (0, 1, 0, 1))
		cb = Colorbar(fig[1, 2]; limits = (0, 2))
		colorbuffer(fig)
		string.(cb.axis.ticklabels[])
	end
end

@testset "theme_SimpleTicks" begin
	cb_on = tick_labels(theme_SimpleTicks())
	cb_off = tick_labels(Theme())
	@test cb_on == [raw"$0$", raw"$0.5$", raw"$1$", raw"$1.5$", raw"$2$"]
	@test "0.0" in cb_off  # fails if the theme does nothing
end

@testset "SimpleTicks on log10 axes" begin
	ticks(a, b) = string.(Makie.get_ticks(SimpleTicks(), log10, Makie.automatic, a, b)[2])
	@test ticks(6, 130) == [raw"$10$", raw"$20$", raw"$50$", raw"$100$"]
	@test ticks(0.05, 0.3) == [raw"$0.05$", raw"$0.1$", raw"$0.2$"]
	@test ticks(1e-3, 10) == [raw"$10^{-3}$", raw"$10^{-2}$", raw"$10^{-1}$", raw"$10^{0}$", raw"$10^{1}$"]
end

@testset "panellabel!" begin
	fig = Figure()
	ax = Axis(fig[1, 1])
	lines!(ax, 0..1, identity)
	n = length(ax.scene.plots)
	p = panellabel!(ax, 2)
	@test only(p.text[]) == "(b)"
	@test length(ax.scene.plots) == n + 9  # 8 halo layers + text
	panellabel!(ax, "(c)"; halo = false, corner = :rb)
	@test length(ax.scene.plots) == n + 10
	@test length(panellabels!([ax, ax]; color = :white)) == 2
	colorbuffer(fig)
end

@testset "SimpleMinorTicks" begin
	minor(scale, ticks, lo, hi) = Makie.get_minor_tickvalues(SimpleMinorTicks(), scale, ticks, lo, hi)
	@test minor(identity, [0.0, 1.0], 0, 1) ≈ [0.2, 0.4, 0.6, 0.8]
	@test minor(identity, [0.0, 2.0], 0, 2) ≈ [0.5, 1.0, 1.5]
	@test minor(identity, [0.0, π / 2, π], 0, π) ≈ [π / 4, 3π / 4]
	@test minor(log10, [10.0, 100.0], 10, 100) ≈ 20:10:90
	with_theme(theme_SimpleTicks(; publication = true)) do
		ax = Axis(Figure()[1, 1])
		@test ax.xminorticksvisible[] && ax.xticksmirrored[] && ax.xtickalign[] == 1
	end
end

@testset "errlines! and numberheatmap!" begin
	fig = Figure()
	ax = Axis(fig[1, 1])
	l = errlines!(ax, 1:5, rand(5), (fill(0.1, 5), fill(0.2, 5)); label = "a", markersize = 6)
	l2 = errlines!(ax, rand(5), fill(0.1, 5); label = "b")
	@test l isa MakieHelpers.ErrLines
	@test Makie.to_color(l.color[]) != Makie.to_color(l2.color[])  # colors cycle
	leg = axislegend(ax)
	@test length(leg.entrygroups[][1][2]) == 2  # one legend entry per curve
	numberheatmap!(Axis(fig[1, 2]), 1:3, 1:2, [0.123456 1; 2 3; 4 5])
	colorbuffer(fig)
end

@testset "0.3.1: PiTicks colorbar, simplestring, legend markers" begin
	@test simplestring(0.0) == "0" && simplestring(0.1) == "0.1" && simplestring(2.50) == "2.5"
	with_theme(theme_PiTicks(; publication = true)) do
		fig = Figure()
		cb = Colorbar(fig[1, 1]; limits = (0, 1))
		@test cb.ticks[] isa SimpleTicks
		ax = Axis(fig[1, 2])
		s = scatter!(ax, 1:3, 1:3; label = "s")
		@test first(s.markersize[]) == 6  # publication marker size
		errorbars!(ax, 1:3, 1:3, fill(0.1, 3); label = "s")
		e = errlines!(ax, 1:3, 1:3, fill(0.1, 3); markersize = 5, label = "e")
		scatter!(ax, 1:3, 1:3; markersize = 14, label = "big")
		leg = axislegend(ax; merge = true)
		sizes(i) = [first(el.attributes[:markersize][]) for el in leg.entrygroups[][1][2][i].elements
		            if el isa MarkerElement && el.attributes[:marker][] ∉ (:hline, :vline)]
		@test sizes(1) == [9]   # small plot markers grow to the Legend's markersize
		@test sizes(2) == [9]   # errlines too
		@test sizes(3) == [14]  # larger ones stay
		colorbuffer(fig)
	end
end
