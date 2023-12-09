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
    steps = 0
    current = [x for x in keys(nodemap) if x[3] == 'A']
    while true
        for char in instructions
            # println(current)
            steps += 1
            for (i, c) in enumerate(current)
                current[i] = nodemap[c][char == 'L' ? 1 : 2]
            end
            ends = filter(x -> x[3] == 'Z', current)
            current == ends && (return steps)
        end
    end
end

println(findoutghost(nodemap))