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
