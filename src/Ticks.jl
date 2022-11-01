function simpleTicks(range::AbstractArray;digits=1,latex = true,kwargs...)
    toString,zero_string = 
    if latex
        Makie.latexstring,L"0"
    else
        string,"0"
    end

    function simplify(x)
        if x ≈ 0.
            return zero_string
        elseif isinteger(x)
            return toString(Int(x))
        else
            return toString(round(x;digits,kwargs...),)
        end
    end
    ticks = simplify.(range)
    return (range,ticks)
end

function simplePiTicks(range::AbstractArray;digits=1,latex = true,kwargs...)
    toString,zero_string,pi_string = 
    if latex
        Makie.latexstring,L"0",L"\pi"
    else
        string,"0","π"
    end

    function simplify_pi(x)
        x = x/π
        if x ≈ 0.
            return zero_string
        elseif isinteger(x)
            return toString(Int(x),pi_string)
        else
            return toString(round(x;digits,kwargs...),pi_string,)
        end
    end
    ticks = simplify_pi.(range)
    return (range,ticks)
end

simpleTicks(n::Integer,min::Real,max::Real;kwargs...) = simpleTicks(LinRange(min,max,n);kwargs...)
simpleTicks(range;kwargs...) = simpleTicks(collect(range);kwargs...)

simplePiTicks(n::Integer,min::Real,max::Real;kwargs...) = simplePiTicks(LinRange(min,max,n);kwargs...)
simplePiTicks(range;kwargs...) = simplePiTicks(collect(range);kwargs...)
