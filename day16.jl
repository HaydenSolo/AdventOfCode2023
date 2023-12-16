include("utils.jl")

input = readmatrix()

abstract type Square end

mutable struct Empty <: Square
    up::Union{Square, Nothing}
    left::Union{Square, Nothing}
    right::Union{Square, Nothing}
    down::Union{Square, Nothing}
    energized::Bool
end
mutable struct ForwardMirror <: Square
    up::Union{Square, Nothing}
    left::Union{Square, Nothing}
    right::Union{Square, Nothing}
    down::Union{Square, Nothing}
    energized::Bool
end
mutable struct BackMirror <: Square
    up::Union{Square, Nothing}
    left::Union{Square, Nothing}
    right::Union{Square, Nothing}
    down::Union{Square, Nothing}
    energized::Bool
end
mutable struct VertSplitter <: Square
    up::Union{Square, Nothing}
    left::Union{Square, Nothing}
    right::Union{Square, Nothing}
    down::Union{Square, Nothing}
    energized::Bool
end
mutable struct HoroSplitter <: Square
    up::Union{Square, Nothing}
    left::Union{Square, Nothing}
    right::Union{Square, Nothing}
    down::Union{Square, Nothing}
    energized::Bool
end
struct Off <: Square end
Square(str::AbstractString) = Dict("."=>Empty, "/"=>ForwardMirror, "\\"=>BackMirror, "|"=>HoroSplitter, "-"=>VertSplitter)[str](nothing, nothing, nothing, nothing, false)
Base.show(io::IO, z::Empty) = print(io, z.energized ? "#" : ".")
Base.show(io::IO, z::ForwardMirror) = print(io, z.energized ? "#" : "/")
Base.show(io::IO, z::BackMirror) = print(io, z.energized ? "#" : "\\")
Base.show(io::IO, z::HoroSplitter) = print(io, z.energized ? "#" : "|")
Base.show(io::IO, z::VertSplitter) = print(io, z.energized ? "#" : "-")

function getgrid(input)
    grid = Square.(input)
    for i in 1:size(grid)[1]
        for j in 1:size(grid)[2]
            square = grid[i,j]
            square.up = i == 1 ? Off() : grid[i-1, j]
            square.down = i == size(grid)[1] ? Off() : grid[i+1, j]
            square.left = j == 1 ? Off() : grid[i, j-1]
            square.right = j == size(grid)[2] ? Off() : grid[i, j+1]
        end
    end
    grid
end
abstract type Direction end
struct North <: Direction end
struct South <: Direction end
struct West <: Direction end
struct East <: Direction end

function visit(square::Square, travelling::Direction)
    square.energized = true
    travel(square, travelling)
end
visit(square::Off, travelling::Direction) = nothing

function removeright(square::Square)
    next = square.right
    square.right = Off()
    next
end
function removeup(square::Square)
    next = square.up
    square.up = Off()
    next
end
function removedown(square::Square)
    next = square.down
    square.down = Off()
    next
end
function removeleft(square::Square)
    next = square.left
    square.left = Off()
    next
end

travel(square::Empty, travelling::North) = visit(removeup(square), North())
travel(square::Empty, travelling::East) = visit(removeright(square), East())
travel(square::Empty, travelling::West) = visit(removeleft(square), West())
travel(square::Empty, travelling::South) = visit(removedown(square), South())

travel(square::ForwardMirror, travelling::North) = visit(removeright(square), East())
travel(square::ForwardMirror, travelling::East) = visit(removeup(square), North())
travel(square::ForwardMirror, travelling::West) = visit(removedown(square), South())
travel(square::ForwardMirror, travelling::South) = visit(removeleft(square), West())

travel(square::BackMirror, travelling::North) = visit(removeleft(square), West())
travel(square::BackMirror, travelling::East) = visit(removedown(square), South())
travel(square::BackMirror, travelling::West) = visit(removeup(square), North())
travel(square::BackMirror, travelling::South) = visit(removeright(square), East())

travel(square::HoroSplitter, travelling::North) = visit(removeup(square), North())
travel(square::HoroSplitter, travelling::East) = (visit(removeup(square), North());visit(removedown(square), South()))
travel(square::HoroSplitter, travelling::West) = (visit(removeup(square), North());visit(removedown(square), South()))
travel(square::HoroSplitter, travelling::South) = visit(removedown(square), South())

travel(square::VertSplitter, travelling::North) = (visit(removeleft(square), West());visit(removeright(square), East()))
travel(square::VertSplitter, travelling::East) = visit(removeright(square), East())
travel(square::VertSplitter, travelling::West) = visit(removeleft(square), West())
travel(square::VertSplitter, travelling::South) = (visit(removeleft(square), West());visit(removeright(square), East()))

grid = getgrid(input)
visit(grid[1,1], East())
energized = [x for x in grid if x.energized]
println(length(energized))

function findbest(input)
    best = 0
    for i in 1:size(input)[1]
        grid = getgrid(input)
        visit(grid[i,1], East())
        energized = [x for x in grid if x.energized]
        length(energized) > best && (best = length(energized))
        # println("Done left $i")
    end
    for i in 1:size(input)[1]
        grid = getgrid(input)
        visit(grid[i,size(input)[2]], West())
        energized = [x for x in grid if x.energized]
        length(energized) > best && (best = length(energized))
        # println("Done right $i")
    end
    for j in 1:size(input)[2]
        grid = getgrid(input)
        visit(grid[1,j], South())
        energized = [x for x in grid if x.energized]
        length(energized) > best && (best = length(energized))
        # println("Done top $j")
    end
    for j in 1:size(input)[2]
        grid = getgrid(input)
        visit(grid[size(input)[1],j], North())
        energized = [x for x in grid if x.energized]
        length(energized) > best && (best = length(energized))
        # println("Done bottom $j")
    end
    return best
end

println(findbest(input))