include("utils.jl")

input = readinput()

function findhistory(line)
    pattern = parseint([match.match for match in eachmatch(r"-*\d+", line)])
    values = [pattern]
    newvalues = [b-a for (a, b) in zip(pattern[1:end-1], pattern[2:end])]
    while !(all(newvalues .== 0))
        push!(values, newvalues)
        newvalues = [b-a for (a, b) in zip(newvalues[1:end-1], newvalues[2:end])]
    end
    flip = reverse(values)
    for (a, b) in zip(flip[1:end-1], flip[2:end])
        push!(b, b[end] + a[end])
    end
    # println(values)
    return values[1][end]
end
       
extrap = findhistory.(input)
println(sum(extrap))

# 3597659930 too high

function findforwardhistory(line)
    pattern = reverse(parseint([match.match for match in eachmatch(r"-*\d+", line)]))
    values = [pattern]
    newvalues = [b-a for (a, b) in zip(pattern[1:end-1], pattern[2:end])]
    while !(all(newvalues .== 0))
        push!(values, newvalues)
        newvalues = [b-a for (a, b) in zip(newvalues[1:end-1], newvalues[2:end])]
    end
    flip = reverse(values)
    for (a, b) in zip(flip[1:end-1], flip[2:end])
        push!(b, b[end] + a[end])
    end
    # println(values)
    return values[1][end]
end
       
extrap = findforwardhistory.(input)
println(sum(extrap))