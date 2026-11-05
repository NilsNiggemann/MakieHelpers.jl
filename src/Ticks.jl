function _simplify(x;sigdigits=7,kwargs...)
    rdInt = round(Int,x;kwargs...)
    if isapprox(rdInt,x;atol = exp10(-sigdigits))
        return rdInt
    else
        return round(x;sigdigits,kwargs...)
    end
end

"""given a string of a float cut off all trailing zeros behind the decimal point"""
function cut_trailing_zeros(s::String)
    if occursin(r"\.",s)
        s = replace(s,r"\.0+$"=>"")
    end
    return s
end
cut_trailing_zeros(x::Real) = cut_trailing_zeros(string(x))

simplifyString(x::Real) = cut_trailing_zeros(_simplify(x))

"""
	simplestring(x)

`x` as a short string, formatted like [`SimpleTicks`](@ref) labels: `0` instead of `0.0`,
`0.1` instead of `0.1000000001`. For labels, e.g. `L"x = %\$(simplestring(x))"`.
"""
simplestring(x::Real) = simplifyString(x)

function simplify_pi(x)
    if x ≈ 0 
        return Makie.latexstring("0")
    elseif abs(x) ≈ 1
        label = ifelse(x>0,"π","-π")
        return Makie.latexstring(label)
    else
        return Makie.latexstring(simplifyString(x),"π")
    end
end

struct PiTicks end

function Makie.get_ticks(::PiTicks, any_scale, ::Makie.Automatic, vmin, vmax)
    vmin = vmin/pi
    vmax = vmax/pi

    vals_s = Makie.get_tickvalues(Makie.automatic, any_scale, vmin, vmax)

    labels = simplify_pi.(vals_s)

    pi.*vals_s, labels
end

struct SimpleTicks end

function SimpleTicks(range::AbstractArray;digits=1,kwargs...)
    range_simp = _simplify.(range;kwargs...)
    return (range_simp,Makie.latexstring.(cut_trailing_zeros.(range_simp)))
end

SimpleTicks(n::Integer,min::Real,max::Real;kwargs...) = SimpleTicks(LinRange(min,max,n);kwargs...)
SimpleTicks(range;kwargs...) = SimpleTicks(collect(range);kwargs...)

function Makie.get_ticks(::SimpleTicks, any_scale, ::Makie.Automatic, vmin, vmax)
    vals_s = Makie.get_tickvalues(Makie.automatic, any_scale, vmin, vmax)
    labels = Makie.latexstring.(simplifyString.(vals_s))
    vals_s, labels
end

const Log10Types = Union{typeof(log10),typeof(Makie.pseudolog10),typeof(Makie.Symlog10(1))}
basisStr(::Log10Types) = "10"
basisStr(::typeof(Makie.Symlog10(1))) = "10"
basisStr(::typeof(log2)) = "2"
basisStr(::typeof(log)) = "e"

function Makie.get_ticks(::SimpleTicks, scale::Union{typeof(log), typeof(log2),Log10Types}, ::Makie.Automatic, vmin, vmax)
    vals_s = Makie.get_tickvalues(LogTicks(WilkinsonTicks(5, k_min = 3)), scale, vmin, vmax)
    basis = basisStr(scale)
    expVal(v) = simplifyString(scale(v))
    sgnstring(x) = ifelse(x<0,"-","")
    labels = [Makie.latexstring("$(sgnstring(v)) $basis^{$(expVal(v))}") for v in vals_s]
    vals_s, labels
end

# log10 axes: whole powers of ten when the range spans at least three of them, otherwise
# 1-2-5 ticks labelled as plain numbers (fractional exponents like 10^{1.5} are hard to read)
function Makie.get_ticks(::SimpleTicks, scale::typeof(log10), ::Makie.Automatic, vmin, vmax)
    lo, hi = log10(vmin), log10(vmax)
    exps = ceil(Int, lo - 1e-9):floor(Int, hi + 1e-9)
    if length(exps) >= 3
        step = cld(length(exps), 6)
        vals = exp10.(exps[1:step:end])
        return vals, [Makie.latexstring("10^{$e}") for e in exps[1:step:end]]
    end
    candidates(ms) = [m * exp10(e) for e in floor(Int, lo):ceil(Int, hi) for m in ms if vmin <= m * exp10(e) <= vmax]
    vals = candidates((1, 2, 5))
    length(vals) > 7 && (vals = candidates((1, 3)))
    length(vals) < 2 && (vals = candidates(1:9))
    return vals, Makie.latexstring.(simplifyString.(vals))
end

"""
	SimpleMinorTicks()

Minor ticks whose count follows the major tick step, for `xminorticks`/`yminorticks`:
a major step of 1, 2 or 5 (times a power of ten) gets minor ticks every 0.2, 0.5 or 1;
a step that is a multiple of π/4 gets minor ticks every π/4 (or π/8 for a π/4 step);
on log10 axes minor ticks sit at every integer mantissa (2, 3, ..., 9 times a power of ten),
only at whole decades when the axis spans more than six of them.
"""
struct SimpleMinorTicks end

function _minor_intervals(step)
	s = abs(step)
	quarters = 4s / π
	if round(quarters) >= 1 && isapprox(quarters, round(quarters); atol = 1e-6)
		return clamp(round(Int, quarters), 2, 4)
	end
	mantissa = round(s / exp10(floor(log10(s))); sigdigits = 3)
	return mantissa ≈ 2 ? 4 : 5
end

function Makie.get_minor_tickvalues(::SimpleMinorTicks, scale, tickvalues, vmin, vmax)
	length(tickvalues) < 2 && return Float64[]
	n = _minor_intervals(tickvalues[2] - tickvalues[1])
	return Makie.get_minor_tickvalues(IntervalsBetween(n, true), scale, tickvalues, float(vmin), float(vmax))
end

function Makie.get_minor_tickvalues(::SimpleMinorTicks, ::typeof(log10), tickvalues, vmin, vmax)
	decades = floor(Int, log10(vmin)):ceil(Int, log10(vmax))
	mantissas = length(decades) > 7 ? (1,) : 1:9
	vals = [m * exp10(e) for e in decades for m in mantissas if vmin <= m * exp10(e) <= vmax]
	return filter(v -> !any(t -> isapprox(v, t; rtol = 1e-6), tickvalues), vals)
end

function PiTicks(range::AbstractArray;digits=1,kwargs...)
    pirange = range ./pi
    ticks = simplify_pi.(pirange)
    range_simp = _simplify.(pirange;kwargs...) .*pi
    return (range_simp,ticks)
end

PiTicks(n::Integer,min::Real,max::Real;kwargs...) = PiTicks(LinRange(min,max,n);kwargs...)
PiTicks(range;kwargs...) = PiTicks(collect(range);kwargs...)
