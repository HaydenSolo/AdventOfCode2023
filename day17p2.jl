include("utils.jl")

input = parseint(readmatrix())

abstract type Direction end
struct Up <: Direction
end
# Up() = Up(0)
struct Left <: Direction
end
# Left() = Left(0)
struct Right <: Direction
end
# Right() = Right(0)
struct Down <: Direction
end
# Down() = Down(0)
struct Undefined <: Direction end

mutable struct Node
    value::Int
    left::Union{Node, Nothing}
    up::Union{Node, Nothing}
    down::Union{Node, Nothing}
    right::Union{Node, Nothing}
    # pathlength::Int
    # direction::Direction
    # directioncounter::Int
    # from::Union{Node, Nothing}
end
pathlength(node) = node.pathlength
Node(value::Int) = Node(value, nothing, nothing, nothing, nothing)
# Node(node::Node, direction::Direction) = Node(node.value, node.left, node.up, node.down, node.right, node.pathlength, direction, 0, node.from)
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

mutable struct NodeDir
    node::Node
    dir::Direction
    straightlen::Int
    pathlength::Int
    from::Union{NodeDir,Nothing}
end
NodeDir(node::Node, dir::Direction, straightlen::Int) = NodeDir(node, dir, straightlen, typemax(Int),nothing)

neighbours(node::Node) = [x for x in [node.up, node.down, node.left, node.right] if x != nothing]

opposing(::Left, ::Right) = true
opposing(::Right, ::Left) = true
opposing(::Up, ::Down) = true
opposing(::Down, ::Up) = true
opposing(::Direction, ::Direction) = false

function neighbours(nodedir::NodeDir, maps::Dict{Node, Vector{NodeDir}})
    ns = NodeDir[]
    node = nodedir.node
    for (neighbour, dir) in [(node.up, Up()), (node.down, Down()), (node.left, Left()), (node.right, Right())]
        neighbour == nothing && continue
        opposing(nodedir.dir, dir) && continue
        nodedir.straightlen < 4 && dir != nodedir.dir && continue
        newlength = dir == nodedir.dir ? nodedir.straightlen + 1 : 1
        newlength == 11 && continue
        all = maps[neighbour]
        for nd in all
            nd.dir == dir && nd.straightlen == newlength && (push!(ns, nd);break)
        end
    end
    ns
end

function findpath(grid, startnode, endnode)
    unvisited = Set{NodeDir}()
    maps = Dict{Node, Vector{NodeDir}}()
    for node in grid
        maps[node] = NodeDir[]
        for dir in [Up(), Left(), Right(), Down()]
            for n in 1:10
                nd = NodeDir(node, dir, n)
                push!(unvisited, nd)
                push!(maps[node], nd)
            end
        end
    end
    # tovisit = Set{NodeDir}()
    # push!(tovisit, NodeDir(startnode, Undefined(), 0))
    push!(unvisited, NodeDir(startnode, Right(), 0, 0, nothing))
    push!(unvisited, NodeDir(startnode, Down(), 0, 0, nothing))
    # startnode.pathlength = 0
    # startnode.direction = Right()
    while true
        nextnode = minimumby(pathlength, unvisited)
        nextnode.node == endnode && nextnode.straightlen >= 4 && return(nextnode)
        for neighbour in neighbours(nextnode, maps)
            len = nextnode.pathlength + neighbour.node.value
            if len < neighbour.pathlength
                # if typeof(direction) == typeof(nextnode.direction) && nextnode.direction.amount == 3
                #     continue
                # end
                neighbour.pathlength = len
                neighbour.from = nextnode
                # if typeof(direction) == typeof(nextnode.direction)
                #     neighbour.direction = typeof(direction)(nextnode.direction.amount+1)
                # else
                #     neighbour.direction = typeof(direction)(1)
                # end
            end
        end
        delete!(unvisited, nextnode)
    end
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
end