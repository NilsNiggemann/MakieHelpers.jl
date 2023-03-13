function _simplify(x;sigdigits=7,kwargs...)
    rdInt = round(Int,x;kwargs...)
    if isapprox(rdInt,x;atol = exp10(-sigdigits))
        return rdInt
    else
        return round(x;sigdigits,kwargs...)
    end
end

function simplify_pi(x)
    if x ≈ 0 
        return Makie.latexstring("0")
    elseif abs(x) ≈ 1
        label = ifelse(x>0,"π","-π")
        return Makie.latexstring(label)
    else
        return Makie.latexstring(_simplify(x),"π")
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
    return (range_simp,Makie.latexstring.(range_simp))
end

SimpleTicks(n::Integer,min::Real,max::Real;kwargs...) = SimpleTicks(LinRange(min,max,n);kwargs...)
SimpleTicks(range;kwargs...) = SimpleTicks(collect(range);kwargs...)

function Makie.get_ticks(::SimpleTicks, any_scale, ::Makie.Automatic, vmin, vmax)
    vals_s = Makie.get_tickvalues(Makie.automatic, any_scale, vmin, vmax)
    labels = Makie.latexstring.(_simplify.(vals_s))
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
    expVal(v) = _simplify(scale(v))
    sgnstring(x) = ifelse(x<0,"-","")
    labels = [Makie.latexstring("$(sgnstring(v)) $basis^{$(expVal(v))}") for v in vals_s]
    vals_s, labels
end

function PiTicks(range::AbstractArray;digits=1,kwargs...)
    pirange = range ./pi
    ticks = simplify_pi.(pirange)
    range_simp = _simplify.(pirange;kwargs...) .*pi
    return (range_simp,ticks)
end

PiTicks(n::Integer,min::Real,max::Real;kwargs...) = PiTicks(LinRange(min,max,n);kwargs...)
PiTicks(range;kwargs...) = PiTicks(collect(range);kwargs...)
