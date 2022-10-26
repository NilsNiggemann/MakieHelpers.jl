function simplePiTicks(n,min,max;sigdigits=1)
    range = LinRange(min,max,n)
    function simplify_pi(x)
        x = x/pi
        if x == 0
            return L"0"
        elseif isinteger(x)
            return latexstring(Int(x),L"\pi")
        else
            return latexstring(round(x;sigdigits),L"\pi")
        end
    end
    ticks = simplify_pi.(range)
    return (range,ticks)
end