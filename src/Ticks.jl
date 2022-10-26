function simplePiTicks(n,min,max;sigdigits=1,latex = true)
    range = LinRange(min,max,n)
    toString,zero_string,pi_string = 
    if latex
        latexstring,L"0",L"\pi"
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
            return toString(round(x;sigdigits),pi_string)
        end
    end
    ticks = simplify_pi.(range)
    return (range,ticks)
end
