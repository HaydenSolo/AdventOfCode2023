include("utils.jl")

input = readmatrix(true)

abstract type Square end

struct Plot <: Square
    neighbours::Vector{Plotcz}
end
Plot() = Plot([])

struct Rock <: Square end

Square(str::AbstractString) = str == "#" ? Rock() : Plot()
Base.show(io::IO, z::Rock) = print(io, "#")
Base.show(io::IO, z::Plot) = print(io, ".")

struct PlotLocation
    plot::Plot
    location::Tuple{Int,Int}
end

function getplots(input)
    plots = Square.(input)
    start = findfirst(==("S"), input)
    for i in 1:size(input)[1]
        for j in 1:size(input)[2]
            plots[i,j] isa Rock && continue
            if i != 1
                plots[i-1, j] isa Plot && push!(plots[i, j].neighbours, plots[i-1, j])
            else
                plots[size(plots)[1], j] isa Plot && push!(plots[i, j].neighbours, plots[size(plots)[1], j])
            end
            if j != 1
                plots[i, j-1] isa Plot && push!(plots[i, j].neighbours, plots[i, j-1])
            else
                plots[i, size(plots)[2]] isa Plot && push!(plots[i, j].neighbours, plots[i, size(plots)[2]])
            end
            if i != size(input)[1]
                plots[i+1, j] isa Plot && push!(plots[i, j].neighbours, plots[i+1, j])
            else
                plots[1, j] isa Plot && push!(plots[i, j].neighbours, plots[1, j])
            end
            if j != size(input)[2]
                plots[i, j+1] isa Plot && push!(plots[i, j].neighbours, plots[i, j+1])
            else
                plots[i, 1] isa Plot && push!(plots[i, j].neighbours, plots[i, 1])
            end
        end
    end
    return plots, plots[start]
end

function main(input; steps=6)
    plots, start = getplots(input)
    tovisit = Set{PlotLocation}()
    push!(tovisit, PlotLocation(start, (1,1)))
    for step in 1:steps
        visiting = Set{PlotLocation}()
        for plot in tovisit
            for neighbour in plot.plot.neighbours
                push!(visiting, neighbour)
            end
        end
        tovisit = visiting
    end
    length(tovisit)
end

println(main(input; steps=6))