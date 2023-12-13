include("utils.jl")

using Combinatorics

input = split.(readinput(true))

function checkline(checking, info)
    matches = [length(match.match) for match in eachmatch(r"#+", checking)]
    lens = join(matches, ",")
    # length(lens) == length(info) && println("$info $lens")
    return lens == info
end

function getpossibilities(len, needed)
    level = [""]
    for i in 1:len
        println("$i $(length(level))")
        new = String[]
        for l in level
            if count(==('#'), l) < needed
                push!(new, l*"#")
            end
            push!(new, l*".")
        end
        level = new
    end
    filter(p -> count(==('#'), p) == needed, level)
end

function getdamaged(line)
    record, info = line
    record = repeat(record*"?", 5)[1:end-1]
    info = repeat(info*",", 5)[1:end-1]
    unknown = findall(isequal('?'), record)
    needed = sum(parseint(split(info, ","))) - count(==('#'), record)
    maxrun = maximum(parseint(split(info, ",")))
    # options = append!(['#' for _ in 1:length(unknown)], ['.' for _ in 1:length(unknown)])
    possibilities = getpossibilities(length(unknown), needed, maxrun)
    println(length(possibilities))
    correct = 0
    for possibility in possibilities
        current = 1
        io = IOBuffer()
        for (i, c) in enumerate(record)
            if i in unknown
                print(io, possibility[current])
                current += 1
            else
                print(io, c)
            end
        end
        checking = String(take!(io))
        checkline(checking, info) && (correct += 1)
    end
    return correct
end

line = input[6]

# println(getdamaged(input[1]))
function main()
total = 0
for (i, line) in enumerate(input)
    total += getdamaged(line)
    println("Completed $i")
end
println(total)
end
# main()