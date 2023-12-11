include("utils.jl")

using Distances
using Combinatorics

galaxy = String.(hcat(split.(readinput(), "")...))

function doublerows(galaxy)
    double = Int[]
    for (i, row) in enumerate(eachrow(galaxy))
        all(isequal.(row, ".")) && push!(double, i)
    end
    return double
end

function doublecols(galaxy)
    double = Int[]
    for (i, col) in enumerate(eachcol(galaxy))
        all(isequal.(col, ".")) && push!(double, i)
    end
    return double
end

rows, cols = doublerows(galaxy), doublecols(galaxy)
planets = findall(isequal("#"), galaxy)
pairs = collect(combinations(planets, 2))

function getdistance(pair, rows, cols; expandto=2)
    base = cityblock(Tuple(pair[1]), Tuple(pair[2]))
    for row in rows
        if pair[1][1] < row < pair[2][1] || pair[2][1] < row < pair[1][1]
            base += expandto-1
        end
    end
    for col in cols
        if pair[1][2] < col < pair[2][2] || pair[2][2] < col < pair[1][2]
            base += expandto-1
        end
    end
    return base
end

println(sum(getdistance.(pairs, Ref(rows), Ref(cols))))
println(sum(getdistance.(pairs, Ref(rows), Ref(cols); expandto=1000000)))