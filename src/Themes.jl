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