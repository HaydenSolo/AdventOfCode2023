include("utils.jl")

using Graphs
using LongestPaths

test = readmatrix(true)
input = readmatrix()

function getedge(verts, i, j, i2, j2)
    ind1 = findfirst(==((i, j)), verts)
    ind2 = findfirst(==((i2, j2)), verts)
    Edge(ind1, ind2)
end

function getgraph(input)
    verts = []
    for i in 1:size(input)[1]
        for j in 1:size(input)[2]
            input[i, j] != "#" && push!(verts, (i,j))
        end
    end
    edges = Edge[]
    for i in 1:size(input)[1]
        for j in 1:size(input)[2]
            input[i, j] == "#" && continue
            i != 1 && input[i-1,j] != "#" && push!(edges, getedge(verts, i, j, i-1, j))
            i != size(input)[1] && input[i+1,j] != "#" && push!(edges, getedge(verts, i, j, i+1, j))
            j != 1 && input[i,j-1] != "#" && push!(edges, getedge(verts, i, j, i, j-1))
            j != size(input)[2] && input[i,j+1] != "#" && push!(edges, getedge(verts, i, j, i, j+1))
        end
    end
    println(length(edges))
    SimpleDiGraphFromIterator(edges)
end

function longestpath(graph)
    first = 1
    final = nv(graph)
    find_longest_path(graph, first, final)
end

function main(input)
    graph = getgraph(input)
    longestpath(graph)
end