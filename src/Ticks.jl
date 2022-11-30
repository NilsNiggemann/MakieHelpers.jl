
"""Example use: makeTicks(Any[-1.5,-1,-0.5,0,0.5,1])"""
makeTicks(ticks) = (ticks,Makie.latexstring.(ticks))

function _simplify(x;digits=1,kwargs...)
    if x ≈ 0.
        return 0
    elseif isinteger(x)
        return Int(x)
    else
        return round(x;digits,kwargs...)
    end
end

function _getToString(latex = true)
    return latex ? Makie.latexstring : string
end

function simpleTicks(range::AbstractArray;latex = true,kwargs...)
    toString = _getToString(latex)

    stringConvert(x) = x ≈ 0 ? toString("0") : toString(x)

    simplify_str(x) = stringConvert(_simplify(x,kwargs...))
    ticks = simplify_str.(range)
    range_simp = _simplify.(range;kwargs...)
    return (range_simp,ticks)
end

simpleTicks(n::Integer,min::Real,max::Real;kwargs...) = simpleTicks(LinRange(min,max,n);kwargs...)
simpleTicks(range;kwargs...) = simpleTicks(collect(range);kwargs...)

function simplePiTicks(range::AbstractArray;latex = true,kwargs...)
    toString = _getToString(latex)

    function simplify_pi(x)
        x = x/π
        if x ≈ 0.
            return toString("0")
        elseif abs(x) ≈ 1
            label = ifelse(x>0,"π","-π")
            return toString(label)
        else
            return toString(_simplify(x;kwargs...),"π")
        end
    end

    ticks = simplify_pi.(range)
    range_simp = _simplify.(range ./pi;kwargs...) .*pi
    return (range_simp,ticks)
end

simplePiTicks(n::Integer,min::Real,max::Real;kwargs...) = simplePiTicks(LinRange(min,max,n);kwargs...)
simplePiTicks(range;kwargs...) = simplePiTicks(collect(range);kwargs...)
