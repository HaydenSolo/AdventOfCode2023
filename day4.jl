include("utils.jl")

input = readinput()

function handlecard(line)
    vals = split(line, ":")[2]
    winning, have = split(vals, "|")
    winningnums, havenums = split(winning), split(have)
    matches = 0
    for h in havenums
        if h in winningnums
            matches += 1
        end
    end
    return matches == 0 ? 0 : 2^(matches-1)
end

cards = handlecard.(input)
# println(sum(cards))

function handlecardpart2(line)
    vals = split(line, ":")[2]
    winning, have = split(vals, "|")
    winningnums, havenums = split(winning), split(have)
    matches = 0
    for h in havenums
        if h in winningnums
            matches += 1
        end
    end
    return matches
end

function handlecards(lines)
    copies = Dict()
    for i in 1:length(lines)
        copies[i] = 1
    end
    for i in 1:length(lines)
        for j in i+1:i+handlecardpart2(lines[i])
            copies[j] += copies[i]
        end
    end
    return copies
end

totalcards = handlecards(input)
println(sum(values(totalcards)))