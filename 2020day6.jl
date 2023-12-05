include("utils.jl")

input = read("input.txt", String)
groups = split.(split(input, "\n\n"), "\n")

unions = length.([union(g...) for g in groups])
println(sum(unions))

intersects = length.([intersect(g...) for g in groups])
println(sum(intersects))