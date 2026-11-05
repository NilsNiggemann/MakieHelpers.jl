const _corners = (lt = ((0, 1), (:left, :top), (1, -1)),
                  rt = ((1, 1), (:right, :top), (-1, -1)),
                  lb = ((0, 0), (:left, :bottom), (1, 1)),
                  rb = ((1, 0), (:right, :bottom), (-1, 1)))

_islight(c) = Makie.Colors.Gray(Makie.to_color(c)).val > 0.5

"""
	panellabel!(ax, label; corner = :lt, color = :black, pad = 4, fontsize = ax.yticklabelsize[],
	            halo = true, halocolor = automatic, halowidth = automatic, haloalpha = automatic,
	            nlayers = 8, z = 100)

Panel label such as "(a)" inside the corner of `ax`, instead of a `Label` in a
`TopLeft()` cell that costs a row of figure space. `label` is any text (String,
LaTeXString, rich text); an `Integer` `i` gives the i-th letter, `panellabel!(ax, 2)` is "(b)".
`corner` is one of `:lt, :rt, :lb, :rb`, and `pad` is the distance from the axis corner in pixels;
keep it above half the halo width, or the halo covers the axis spine.

The label sits on a soft halo so that data passing underneath fades out: black text gets a
white halo (line plots), light text a softer dark one (heatmaps, use
`color = :white`). The halo is drawn as `nlayers` stacked translucent strokes of growing
width, so it stays vector in a PDF. `halo = false` draws plain text.

Returns the text plot.

	panellabel!(ax1, 1)                                # line plot
	panellabel!(ax2, 2; color = :white)                # heatmap
	panellabel!(ax3, L"(c)\\; T = 0.03")               # label with a short descriptor
"""
function panellabel!(ax, label; corner = :lt, color = :black, pad = 4,
                     fontsize = ax.yticklabelsize[], font = :regular,
                     halo = true, halocolor = Makie.automatic, halowidth = Makie.automatic,
                     haloalpha = Makie.automatic, nlayers = 8, z = 100)
	pos, align, sgn = _corners[corner]
	kw = (; space = :relative, align, offset = (sgn[1] * pad, sgn[2] * pad), fontsize, font)
	light = _islight(color)
	if halo
		hc = halocolor === Makie.automatic ? (light ? :black : :white) : halocolor
		w = halowidth === Makie.automatic ? (light ? 5 : 6) : halowidth
		α = haloalpha === Makie.automatic ? (light ? 0.6 : 0.95) : haloalpha
		# per-layer alpha so that the stacked layers add up to α at the glyph edge
		αk = 1 - (1 - α)^(1 / nlayers)
		for k in nlayers:-1:1
			p = text!(ax, pos...; text = label, color = (color, 0), strokecolor = (hc, αk),
			          strokewidth = w * k / nlayers, kw...)
			translate!(p, 0, 0, z)
		end
	end
	p = text!(ax, pos...; text = label, color, kw...)
	translate!(p, 0, 0, z)
	return p
end

panellabel!(ax, i::Integer; kwargs...) = panellabel!(ax, "($('a' + i - 1))"; kwargs...)

"""
	panellabels!(axes; kwargs...)

Label `axes` in order as (a), (b), ...; keyword arguments go to [`panellabel!`](@ref).
Pass a vector, e.g. `panellabels!([ax1, ax2]; color = :white)`.
"""
panellabels!(axes; kwargs...) = [panellabel!(ax, i; kwargs...) for (i, ax) in enumerate(axes)]
