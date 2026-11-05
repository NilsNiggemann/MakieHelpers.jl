"""
	errorbarelement(; color = :black, linewidth = 1.5, whiskerwidth = 10, direction = :y)

Legend glyph of an error bar: a vertical line with caps (`direction = :x` for a horizontal one).
Use it in a hand-built legend, alone or together with a `MarkerElement`:

	Legend(fig[1, 2], [[errorbarelement(color = :red), MarkerElement(marker = :circle, color = :red)]], [L"data\$\$"])

`errorbars!` and `errlines!` plots get this glyph in automatic legends.
"""
function errorbarelement(; color = :black, linewidth = 1.5, whiskerwidth = 10, direction = :y)
	ends = direction == :y ? [Point2f(0.5, 0.1), Point2f(0.5, 0.9)] : [Point2f(0.1, 0.5), Point2f(0.9, 0.5)]
	return [LineElement(; linepoints = ends, color, linewidth),
	        MarkerElement(; points = ends, marker = direction == :y ? :hline : :vline,
	                      markersize = whiskerwidth, color, strokewidth = 0)]
end

# Legend markers at least as large as the Legend's markersize (9 by default), so the small markers
# of the publication theme (6) stay readable next to the error-bar glyph. Makie defines this method
# for all Scatter plots; the narrower signature (2D points, every Axis scatter) adds a method instead
# of overwriting Makie's, and reuses it. A `label => (; markersize)` override still wins.
function _legendmarkersize(ms, legend)
	default = Makie.to_value(legend.markersize)
	ms isa Real && return max(ms, default)
	ms isa Makie.VecTypes{2} && return max.(ms, default)
	return default  # per-point sizes: the legend default, as in Makie
end

function Makie.legendelements(plot::Scatter{<:Tuple{AbstractVector{<:Point2}}}, legend)
	elements = invoke(Makie.legendelements, Tuple{Scatter, Any}, plot, legend)
	ms = _legendmarkersize(Makie.to_value(plot.markersize), legend)
	for el in elements
		el.attributes[:markersize] = ms isa Real ? Vec2f(ms, ms) : Vec2f(ms)  # stored as Vec2f
	end
	return elements
end

# vertical error bars with caps instead of Makie's default horizontal line
function Makie.legendelements(plot::Errorbars, legend)
	return errorbarelement(; color = Makie.to_color(plot.color[]), linewidth = plot.linewidth[],
	                       whiskerwidth = max(plot.whiskerwidth[], 6), direction = plot.direction[])
end

"""
	errlines(x, y, err; kwargs...)
	errlines!(ax, x, y, err; kwargs...)

Line through `(x, y)` with a shaded band `y ± err` underneath. `err` is a vector, or a
tuple `(lower, upper)` of vectors for asymmetric errors; `errlines!(y, err)` uses `x = eachindex(y)`.
With `markersize > 0` the points also get markers and error bars. Colors cycle like `lines!`.
The legend shows one entry per curve: the line, plus marker and error bar when `markersize > 0`.
"""
@recipe ErrLines (x, y, err) begin
	color = @inherit linecolor
	linewidth = @inherit linewidth
	linestyle = nothing
	marker = @inherit marker
	"Marker size; 0 draws the line and band only."
	markersize = 0
	"Opacity of the band."
	bandalpha = 0.25
	"Further keyword arguments for the band."
	bandkwargs = (;)
	whiskerwidth = 6
	cycle = [:color]
end

Makie.convert_arguments(::Type{<:ErrLines}, y::AbstractVector, err) = (collect(eachindex(y)), y, err)

_lower(err) = err isa Tuple ? err[1] : err
_upper(err) = err isa Tuple ? err[2] : err

function Makie.plot!(p::ErrLines)
	x, y, err = p[1], p[2], p[3]
	lo = lift((y, e) -> y .- _lower(e), p, y, err)
	hi = lift((y, e) -> y .+ _upper(e), p, y, err)
	bandcolor = lift((c, a) -> (Makie.to_color(c), a), p, p.color, p.bandalpha)
	band!(p, x, lo, hi; color = bandcolor, p.bandkwargs[]...)  # first, so it lies below the line
	scatterlines!(p, x, y; color = p.color, linewidth = p.linewidth, linestyle = p.linestyle,
	              marker = p.marker, markersize = p.markersize)
	errorbars!(p, x, y, lift(_lower, p, err), lift(_upper, p, err); color = p.color,
	           whiskerwidth = p.whiskerwidth, visible = lift(>(0), p, p.markersize))
	return p
end

function Makie.legendelements(p::ErrLines, legend)
	color = Makie.to_color(p.color[])
	line = LineElement(; color, linewidth = p.linewidth[], linestyle = p.linestyle[])
	p.markersize[] > 0 || return [line]
	return [line, errorbarelement(; color, whiskerwidth = 8)...,
	        MarkerElement(; color, marker = p.marker[], markersize = _legendmarkersize(p.markersize[], legend),
	                      strokewidth = 0)]
end
