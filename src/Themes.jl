function theme_SimpleTicks(;latex = true)
	theme = Theme(
		Axis = (
			xticks = SimpleTicks(),
			yticks = SimpleTicks(),
		),
		Axis3 = (
			xticks = SimpleTicks(),
			yticks = SimpleTicks(),
			zticks = SimpleTicks(),
		),
		Colorbar = (ticks = SimpleTicks(),),
	)
	if latex
		theme = merge(theme, theme_latexfonts())
	end
	return theme
end

function theme_PiTicks(;latex = true)
	theme = Theme(
		Axis = (
			xticks = PiTicks(),
			yticks = PiTicks(),
		),
		Axis3 = (
			xticks = PiTicks(),
			yticks = PiTicks(),
			zticks = PiTicks(),
		),
		LScene = (
			xticks = PiTicks(),
			yticks = PiTicks(),
			zticks = PiTicks(),
		),
	)
	if latex
		theme = merge(theme, theme_latexfonts())
	end
	return theme
end
vv() = 2

"""
Colors of the fancy theme by role: `ink` for titles and labels, `muted` for ticks,
tick labels and subtitles, `paper` and `grid` for the axis surface, and accents
`main`, `highlight`, `target` for the data. Pick accents from here in plot code,
e.g. `color = fancy_style.highlight`.
"""
const fancy_style = (;
	ink = colorant"#1F2A36", muted = colorant"#6B7682",
	paper = colorant"#FBFAF6", grid = colorant"#E8E2D6",
	main = colorant"#167A73", highlight = colorant"#C8385A", target = colorant"#E9A23B",
)

"""
	theme_fancy(; style = fancy_style, base = theme_SimpleTicks())

Polished look for presentation figures: left-aligned title with a muted subtitle,
warm paper axis background, quiet frame without top and right spines, short major
and minor ticks, and a framed, nearly opaque legend. `style` supplies the colors
(same fields as `fancy_style`); `base` supplies ticks and latex fonts and loses
wherever both set the same attribute.

	with_theme(theme_fancy()) do
		fig = Figure()
		ax = Axis(fig[1, 1]; title = L"What it shows\$\$", subtitle = L"Setup\$\$")
		...
	end

Per-plot touches are not themeable and stay in plot code: halo under the hero line,
`merge = true` in `axislegend`, `rasterize` on dense scatters.
"""
function theme_fancy(; style = fancy_style, base = theme_SimpleTicks())
	fancy = Theme(
		backgroundcolor = :white,
		textcolor = style.ink,
		palette = (color = [style.main, style.highlight, style.target, style.ink, style.muted],),
		Axis = (
			titlealign = :left, titlesize = 20, subtitlesize = 14,
			titlecolor = style.ink, subtitlecolor = style.muted,
			xlabelcolor = style.ink, ylabelcolor = style.ink,
			xticklabelcolor = style.muted, yticklabelcolor = style.muted,
			xtickcolor = style.muted, ytickcolor = style.muted,
			backgroundcolor = style.paper,
			xgridcolor = style.grid, ygridcolor = style.grid,
			xgridwidth = 1, ygridwidth = 1,
			topspinevisible = false, rightspinevisible = false,
			leftspinecolor = style.muted, bottomspinecolor = style.muted,
			xticksize = 4, yticksize = 4,
			xminorticks = IntervalsBetween(5), yminorticks = IntervalsBetween(4),
			xminorticksvisible = true, yminorticksvisible = true,
			xminorticksize = 2.5, yminorticksize = 2.5,
			xminortickcolor = style.muted, yminortickcolor = style.muted,
		),
		Legend = (
			framecolor = style.grid,
			backgroundcolor = (:white, 0.92),
			labelcolor = style.ink, titlecolor = style.ink,
			labelsize = 13,
			padding = (12, 12, 8, 8),
		),
		Colorbar = (
			labelcolor = style.ink, labelsize = 13,
			ticklabelcolor = style.muted, ticklabelsize = 11,
			tickcolor = style.muted,
			spinewidth = 0,
		),
		Label = (color = style.ink,),
		Lines = (linewidth = 2.5, joinstyle = :round),
		Poly = (strokecolor = style.target, strokewidth = 1.2),
	)
	return merge(fancy, base)
end

"""
Colors of the presentation theme: `fancy_style` with more contrast, since projectors
wash out pale tones. Tick labels are dark, the grid stays visible and the axis
background is plain white.
"""
const presentation_style = (; fancy_style...,
	muted = colorant"#3F4A56", paper = colorant"#FFFFFF", grid = colorant"#D2C8B6",
)

"""
	theme_presentation(; style = presentation_style, base = theme_SimpleTicks())

`theme_fancy` for slides (beamer, projector): large text throughout, thick lines,
spines and ticks, big markers, and minor ticks turned off because they are
invisible from the back of the room. Sizes are meant for a figure of about
`size = (800, 450)` filling most of a 16:9 slide; a larger figure shrinks the text on the slide.

	with_theme(theme_presentation()) do
		fig = Figure(size = (800, 450))
		...
	end
"""
function theme_presentation(; style = presentation_style, base = theme_SimpleTicks())
	presentation = Theme(
		fontsize = 22,
		Axis = (
			titlesize = 30, subtitlesize = 22,
			xlabelsize = 26, ylabelsize = 26,
			xticklabelsize = 22, yticklabelsize = 22,
			spinewidth = 2,
			xtickwidth = 2, ytickwidth = 2,
			xticksize = 8, yticksize = 8,
			xgridwidth = 1.5, ygridwidth = 1.5,
			xminorticksvisible = false, yminorticksvisible = false,
		),
		Legend = (
			labelsize = 22, titlesize = 24,
			patchsize = (35, 25), linewidth = 4, markersize = 16,
			framewidth = 1.5,
		),
		Colorbar = (
			labelsize = 24, ticklabelsize = 20,
			tickwidth = 2, ticksize = 8,
		),
		Label = (fontsize = 24,),
		Lines = (linewidth = 4,),
		Scatter = (markersize = 14,),
		Poly = (strokewidth = 2,),
	)
	return merge(presentation, theme_fancy(; style, base))
end
