include("utils.jl")

input = readinput()

instructions = input[1]
nodes = input[3:end]
nodemap = Dict()
for node in nodes
    name, left, right = [match.match for match in eachmatch(r"\w+", node)]
    nodemap[name] = (left, right)
end

function findout(nodemap)
    steps = 0
    current = "AAA"
    while true
        for char in instructions
            steps += 1
            current = nodemap[current][char == 'L' ? 1 : 2]
            current == "ZZZ" && (return steps)
        end
    end
end

println(findout(nodemap))

function findoutghost(nodemap)
    starts = [x for x in keys(nodemap) if x[3] == 'A']
    found = []
    for start in starts
        steps = 0
        current = start
        flen = length(found)
        while true
            for char in instructions
                steps += 1
                current = nodemap[current][char == 'L' ? 1 : 2]
                current[3] == 'Z' && push!(found, steps)
            end
            length(found) > flen && break
        end
    end
    println(found)
    return lcm(found...)
end

println(findoutghost(nodemap))
