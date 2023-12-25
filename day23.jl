include("utils.jl")

test = readmatrix(true)
input = readmatrix()

abstract type Square end

struct Forest <: Square end
struct Path <: Square 
    neighbours::Vector{Square}
end
mutable struct Slope <: Square 
    neighbour::Union{Square,Nothing}
    dir::Symbol
end

function Square(str::AbstractString)
    str == "#" && return(Forest())
    str == "." && return(Path([]))
    map = Dict(">"=>:right, "<"=>:left, "^"=>:up, "v"=>:down)
    # Slope(nothing, map[str])
    Path([])
end

Base.show(io::IO, ::Forest) = print(io, "#")
Base.show(io::IO, ::Path) = print(io, ".")
function Base.show(io::IO, s::Slope) 
    map = Dict(:right=>">", :left=>"<", :up=>"^", :down=>"v")
    print(io, map[s.dir])
end

neighbours(::Forest) = Square[]
neighbours(p::Path) = p.neighbours
neighbours(s::Slope) = Square[s.neighbour]

addneighbour(::Forest, ::Square, ::Symbol) = nothing
addneighbour(p::Path, s::Square, ::Symbol) = s isa Forest || push!(p.neighbours, s)
addneighbour(sl::Slope, s::Square, direction::Symbol) = s isa Forest || (direction == sl.dir && (sl.neighbour = s))

function getgrid(input)
    grid = Square.(input)
    for i in 1:size(grid)[1]
        for j in 1:size(grid)[2]
            node = grid[i,j]
            i == 1 || addneighbour(node, grid[i-1, j], :up)
            i == size(grid)[1] || addneighbour(node, grid[i+1, j], :down)
            j == 1 || addneighbour(node, grid[i, j-1], :left)
            j == size(grid)[2] || addneighbour(node, grid[i, j+1], :right)
        end
    end
    grid
end

struct Walk
    squares::Vector{Square}
end
Walk() = Walk(Vector{Square}())
function Walk(sq::Square) 
    squares = Vector{Square}()
    push!(squares, sq)
    Walk(squares)
end
Base.length(w::Walk) = length(w.squares)

function extendwalk(walk::Walk, target::Square)
    # println(length(walk.squares))
    last = walk.squares[end]
    last == target && return(Walk[walk])
    walks = Walk[]
    for neighbour in neighbours(last)
        neighbour in walk.squares && continue
        
        newwalk = Walk(copy(walk.squares))
        push!(newwalk.squares, neighbour)
        walks = vcat(walks, extendwalk(newwalk, target))
    end
    walks
end

function getpath(input)
    grid = getgrid(input)
    start = grid[findfirst(==("."), input)]
    target = grid[findlast(==("."), input)]
    walks = extendwalk(Walk(start), target)
    return maximum(length.(walks))-1
end