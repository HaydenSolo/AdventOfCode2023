include("utils.jl")

input = readinput()

struct Part
    positions::Vector{Tuple{Int64, Int64}}
    val::Int
end


parts = Part[]
for (i, row) in enumerate(eachrow(input))
    matches = [ match for match in eachmatch(r"[0-9]+", row[1])]
    for match in matches
        start = match.offset
        positions = []
        for j in start:start+length(match.match)-1
            push!(positions, (j, i))
        end
        push!(parts, Part(positions, parseint(match.match)))
    end
end


lines = split.(input, "")

mat = hcat(lines...)

function checkposition(position::Tuple{Int64, Int64}, mat)
    eachneighbour = [
        (position[1]-1, position[2]-1),
        (position[1]-1, position[2]+1),
        (position[1]-1, position[2]),
        (position[1]+1, position[2]-1),
        (position[1]+1, position[2]+1),
        (position[1]+1, position[2]),
        (position[1], position[2]-1),
        (position[1], position[2]+1),
        (position[1], position[2])
    ]
    for neigbour in eachneighbour
        neigbour[1] > 0 && neigbour[2] > 0 && neigbour[1] <= size(mat)[1] && neigbour[2] <= size(mat)[1] && !isdigit(mat[neigbour[1], neigbour[2]][1]) && mat[neigbour[1],neigbour[2]] != "." && (return true)
    end
    return false
end

function checkpart(part::Part, mat)
    for position in part.positions
        checkposition(position, mat) && (return part.val)
    end
    return 0
end

correct = checkpart.(parts, Ref(mat))
println(sum(correct))

struct Gear
    position::Tuple{Int64, Int64}
end

gears = Gear[]
for (i, row) in enumerate(eachrow(input))
    matches = [ match for match in eachmatch(r"\*", row[1])]
    for match in matches
        position = (match.offset, i)
        push!(gears, Gear(position))
    end
end

function checkgear(gear::Gear, parts::Vector{Part})
    adjacent = []
    current = gear.position
    for part in parts
        for position in part.positions
            if current[1]-1 <= position[1] <= current[1]+1 && current[2]-1 <= position[2] <= current[2]+1
                push!(adjacent, part)
            end
        end
    end
    uniqueparts = unique(adjacent)
    length(uniqueparts) == 2 || (return 0)
    return uniqueparts[1].val * uniqueparts[2].val
end

gearvals = checkgear.(gears, Ref(parts))
println(sum(gearvals))