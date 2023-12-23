include("utils.jl")

using DataStructures

test = readinput(true)
input = readinput()

mutable struct Brick
    x1::Int
    y1::Int
    z1::Int
    x2::Int
    y2::Int
    z2::Int
    supporting::Set{Brick}
    supportedby::Set{Brick}
end
Base.show(io::IO, z::Brick) = print(io, "($(z.x1), $(z.y1), $(z.z1)) to ($(z.x2), $(z.y2), $(z.z2)) supporting $(length(z.supporting)) bricks")
Brick(x1::Int, y1::Int, z1::Int, x2::Int, y2::Int, z2::Int) = Brick(x1,y1,z1,x2,y2,z2,Set{Brick}(),Set{Brick}())
Brick(line::String) = Brick(parseint([match.match for match in eachmatch(r"\d+", line)])...)
Base.isless(b1::Brick, b2::Brick) = min(b1.z1, b1.z2) < min(b2.z1, b2.z2)

bricks = sort(Brick.(input))

struct Square
    x::Int
    y::Int
    z::Int
end
function squares(brick::Brick)
    s = Square[]
    for x in min(brick.x1, brick.x2):max(brick.x1, brick.x2)
        for y in min(brick.y1, brick.y2):max(brick.y1, brick.y2)
            for z in min(brick.z1, brick.z2):max(brick.z1, brick.z2)
                push!(s, Square(x,y,z))
            end
        end
    end
    s
end
down(square::Square) = Square(square.x, square.y, square.z-1)
down(brick::Brick) = Brick(brick.x1,brick.y1,brick.z1-1,brick.x2,brick.y2,brick.z2-1,brick.supporting,brick.supportedby)

function copyfrom(into::Brick, from::Brick)
    into.x1 = from.x1
    into.x2 = from.x2
    into.y1 = from.y1
    into.y2 = from.y2
    into.z1 = from.z1
    into.z2 = from.z2
    into.supporting = from.supporting
    into.supportedby = from.supportedby
    into
end

function Base.fill!(filledsquares::Dict{Square, Brick}, brick::Brick)
    for square in squares(brick)
        filledsquares[square] = brick
    end
end

function movedown(brick::Brick, filledsquares::Dict{Square, Brick})
    originalbrick = brick
    while true
        if min(brick.z1, brick.z2) == 1
            copyfrom(originalbrick, brick)
            fill!(filledsquares, originalbrick)
            return originalbrick
        end
        currentsquares = squares(brick)
        downs = down.(currentsquares)
        blocked = false
        for square in downs
            if square in keys(filledsquares)
                blocked = true
                push!(filledsquares[square].supporting, originalbrick)
                push!(originalbrick.supportedby, filledsquares[square])
            end
        end
        if blocked
            copyfrom(originalbrick, brick)
            fill!(filledsquares, originalbrick)
            return originalbrick
        end
        brick = down(brick)
    end
end

function movedown(bricks::Vector{Brick})
    filledsquares = Dict{Square, Brick}()
    for brick in bricks
        movedown(brick, filledsquares)
    end
    return filledsquares
end

function disintigrate(brick::Brick, counts::Dict{Brick, Int})
    for supporting in brick.supporting
        counts[supporting] == 1 && return(false)
    end
    return true
end

function disintigrate(bricks::Vector{Brick})
    counts = Dict{Brick, Int}([brick=>0 for brick in bricks])
    for brick in bricks
        for supporting in brick.supporting
            counts[supporting] += 1
        end
    end
    safe = disintigrate.(bricks, Ref(counts))
    return sum(safe)
end
    

function main(input)
    bricks = sort(Brick.(input))
    filledsquares = movedown(bricks)
    println(disintigrate(bricks))
    bricks
end

function chain(brick::Brick)
    falling = Set{Brick}()
    tocheck = Queue{Brick}()
    counted = Set{Brick}()
    push!(falling, brick)
    for b in brick.supporting
        enqueue!(tocheck, b)
    end
    count = 0
    while !isempty(tocheck)
        brick = dequeue!(tocheck)
        if all(in.(brick.supportedby, Ref(falling)))
            push!(falling, brick)
            for b in brick.supporting
                enqueue!(tocheck, b)
            end
            brick in counted && continue
            push!(counted, brick)
            count += 1
        end
    end
    count
end

function mainp2(input)
    bricks = sort(Brick.(input))
    filledsquares = movedown(bricks)
    sum(chain.(bricks))
end