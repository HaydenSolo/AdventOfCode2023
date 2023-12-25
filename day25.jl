include("utils.jl")

using Graphs

test = readinput(true)
input = readinput()

function getgraph(input)
    getname(x) = split(x, ":")[1]
    names = getname.(input)
    edges = Edge[]
    for (i, line) in enumerate(input)
        for con in split(split(line, ":")[2])
            j = findfirst(==(con), names)
            j == nothing && (push!(names, con);j = length(names))
            push!(edges, Edge(i, j))
        end
    end
    SimpleGraphFromIterator(edges)
end

graph = getgraph(test)

function part1(input)
    graph = getgraph(input)
    cost = 0
    cut = []
    while cost != 3
        cut = karger_min_cut(graph)
        cost = karger_cut_cost(graph, cut)
    end
    first = [v for v in cut if v == 1]
    second = [v for v in cut if v == 2]
    println(length(first), " ", length(second))
    println(length(first)*length(second))
end