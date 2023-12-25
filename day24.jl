include("utils.jl")

using Combinatorics
import ScikitSpatial as ss

test = readinput(true)
input = readinput()

struct Hailstone
    x::Float64
    y::Float64
    z::Float64
    dx::Float64
    dy::Float64
    dz::Float64
end
Hailstone(line::AbstractString) = Hailstone(parseint([match.match for match in eachmatch(r"-?\d+", line)])...)

function gettime(start::Float64, d::Float64, from::Int, to::Int)
    totravel = (d > 0 ? to : from) - start
    return totravel / d
end

function getfinal(stone::Hailstone, from::Int, to::Int)
    times = [gettime(start, d, from, to) for (start, d) in [(stone.x,stone.dx),(stone.y,stone.dy)]]
    t = minimum(times)
    final = Hailstone(stone.x + stone.dx*t, stone.y + stone.dy*t, stone.z + stone.dz*t, stone.dx, stone.dy, stone.dz)
end

struct Line
    startx::Float64
    starty::Float64
    startz::Float64
    endx::Float64
    endy::Float64
    endz::Float64
end
Line(start::Hailstone, en::Hailstone) = Line(start.x, start.y, start.z, en.x, en.y, en.z)

function testcross(line1::Line, line2::Line)
    l1 = ss.Line([line1.startx, line1.endx], [line1.starty, line1.endy])
    l2 = ss.Line([line2.startx, line2.endx], [line2.starty, line2.endy])
    # l1xstart = line1.startx > line2.startx
    # l1xend = line1.endx > line2.endx
    # xcross = xor(l1xstart, l1xend)

    # l1ystart = line1.starty > line2.starty
    # l1yend = line1.endy > line2.endy
    # ycross = xor(l1ystart, l1yend)

    # println(xcross)
    # println(ycross)
    # return xcross && ycross
end

function intersectcheck(h1::Hailstone, h2::Hailstone, from::Int, to::Int)
    l1 = ss.Line([h1.x, h1.y], [h1.dx, h1.dy])
    l2 = ss.Line([h2.x, h2.y], [h2.dx, h2.dy])
    ss.are_parallel(l1.direction, l2.direction) && return(false)
    inter = ss.intersect(l1, l2)

    (from <= inter[1] <= to && from <= inter[2] <= to) || return(false)

    interx, intery = inter
    h1.dx > 0 && interx < h1.x && return(false)
    h2.dx > 0 && interx < h2.x && return(false)

    h1.dx < 0 && interx > h1.x && return(false)
    h2.dx < 0 && interx > h2.x && return(false)

    h1.dy > 0 && intery < h1.y && return(false)
    h2.dy > 0 && intery < h2.y && return(false)

    h1.dy < 0 && intery > h1.y && return(false)
    h2.dy < 0 && intery > h2.y && return(false)
    true
end

function main(input, from=7, to=27)
    hailstones = Hailstone.(input)
    # finals = getfinal.(hailstones, from, to)
    # lines = Line.(hailstones, finals)
    total = 0
    for combination in combinations(hailstones, 2)
        if intersectcheck(combination[1], combination[2], from, to)
            total += 1
        end
    end
    total
end