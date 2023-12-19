include("utils.jl")

input = parseint(readmatrix(true))

abstract type Direction end
struct Up <: Direction
end
Up() = Up(0)
struct Left <: Direction
end
Left() = Left(0)
struct Right <: Direction
end
Right() = Right(0)
struct Down <: Direction
end
Down() = Down(0)
struct Undefined <: Direction end

mutable struct Node
    value::Int
    left::Union{Node, Nothing}
    up::Union{Node, Nothing}
    down::Union{Node, Nothing}
    right::Union{Node, Nothing}
    pathlength::Int
    direction::Direction
    directioncounter::Int
    from::Union{Node, Nothing}
end
pathlength(node::Node) = node.pathlength
Node(value::Int) = Node(value, nothing, nothing, nothing, nothing, typemax(Int), Undefined(), 0, nothing)
Node(node::Node, direction::Direction) = Node(node.value, node.left, node.up, node.down, node.right, node.pathlength, direction, 0, node.from)
Base.show(io::IO, z::Node) = print(io, z.value)

function getgrid(input)
    grid = Node.(input)
    for i in 1:size(grid)[1]
        for j in 1:size(grid)[2]
            node = grid[i,j]
            node.up = i == 1 ? nothing : grid[i-1, j]
            node.down = i == size(grid)[1] ? nothing : grid[i+1, j]
            node.left = j == 1 ? nothing : grid[i, j-1]
            node.right = j == size(grid)[2] ? nothing : grid[i, j+1]
        end
    end
    grid
end

minimumby(f, iter) = reduce(iter) do x, y
    f(x) < f(y) ? x : y
end

neighbours(node::Node) = [x for x in [(node.up, Up()), (node.down, Down()), (node.left, Left()), (node.right,Right())] if x[1] != nothing]

function findpath(grid, startnode, endnode)
    unvisited = Set(grid)
    startnode.pathlength = 0
    startnode.direction = Right()
    while endnode in unvisited
        nextnode = minimumby(pathlength, unvisited)
        for (neighbour, direction) in neighbours(nextnode)
            len = nextnode.pathlength + neighbour.value
            if len < neighbour.pathlength
                if typeof(direction) == typeof(nextnode.direction) && nextnode.direction.amount == 3
                    continue
                end
                neighbour.pathlength = len
                neighbour.from = nextnode
                if typeof(direction) == typeof(nextnode.direction)
                    neighbour.direction = typeof(direction)(nextnode.direction.amount+1)
                else
                    neighbour.direction = typeof(direction)(1)
                end
            end
        end
        delete!(unvisited, nextnode)
    end
    return grid
end
findpath(input) = (grid=getgrid(input);findpath(grid, grid[1], grid[end]))
        
function getpath(grid)
    current = grid[end]
    path = []
    while current != nothing
        push!(path, current)
        current = current.from
    end
    path
end



# Base.show(io::IO, z::Node) = print(io, z in path ? "#" : z.value)

function test(input)
    grid = findpath(input)
    path = getpath(grid)
    grid, path
end