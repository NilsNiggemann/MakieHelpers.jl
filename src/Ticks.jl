function _simplify(x;digits=1,kwargs...)
    if x ≈ 0.
        return 0
    elseif isinteger(x)
        return Int(x)
    else
        return round(x;digits,kwargs...)
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

function Makie.get_ticks(::SimpleTicks, any_scale, ::Makie.Automatic, vmin, vmax)
    vals_s = Makie.get_tickvalues(Makie.automatic, any_scale, vmin, vmax)
    labels = Makie.latexstring.(_simplify.(vals_s))
    vals_s, labels
end