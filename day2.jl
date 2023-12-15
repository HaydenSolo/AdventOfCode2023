include("utils.jl")

input = readinput(true)

function getgame(line)
    cubes = Dict("red"=>12, "green"=>13, "blue"=>14)
    start, endd = split(line, ":")
    games = split(endd, ";")
    for game in games
        counts = Dict("red"=>0, "green"=>0, "blue"=>0)
        each = split(game, ",")
        for e in each
            a, b = split(e)
            counts[b] += parseint(a)
        end
        for count in keys(counts)
            if counts[count] > cubes[count]
                return 0
            end
        end
    end
    return parseint(split(start)[2])
end

output = getgame.(input)
println(sum(output))

function getpower(line)
    mins = Dict("red"=>0, "green"=>0, "blue"=>0)
    start, endd = split(line, ":")
    games = split(endd, ";")
    for game in games
        counts = Dict("red"=>0, "green"=>0, "blue"=>0)
        each = split(game, ",")
        for e in each
            a, b = split(e)
            counts[b] += parseint(a)
        end
        for count in keys(counts)
            if counts[count] > mins[count]
                mins[count] = counts[count]
            end
        end
    end
    pow = 1
    for val in values(mins)
        pow *= val
    end
    return pow
end

output = getpower.(input)
println(sum(output))
