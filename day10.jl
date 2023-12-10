include("utils.jl")

input = readinput()

maketypes(:UP, :DOWN, :LEFT, :RIGHT)

vert(from::UP) = DOWN()
vert(from::DOWN) = UP()
vert(x) = nothing

hori(from::LEFT) = RIGHT()
hori(from::RIGHT) = LEFT()
hori(x) = nothing

L(from::UP) = RIGHT()
L(from::RIGHT) = UP()
L(x) = nothing

J(from::UP) = LEFT()
J(from::LEFT) = UP()
J(x) = nothing

sev(from::DOWN) = LEFT()
sev(from::LEFT) = DOWN()
sev(x) = nothing

F(from::DOWN) = RIGHT()
F(from::RIGHT) = DOWN()
F(x) = nothing

flip(x::UP) = DOWN()
flip(x::DOWN) = UP()
flip(x::LEFT) = RIGHT()
flip(x::RIGHT) = LEFT()

maze = String.(hcat(split.(input, "")...))
flipmaze = similar(maze, String, size(maze)[2], size(maze)[1])
for i in 1:size(maze)[1]
    for j in 1:size(maze)[2]
        flipmaze[j, i] = maze[i, j]
    end
end
maze = flipmaze
start = findfirst(isequal("S"), maze)
getfun = Dict("|"=>vert, "-"=>hori, "L"=>L, "J"=>J, "7"=>sev, "F"=>F, "."=>x -> nothing)

move(from::CartesianIndex, dir::LEFT) = from + CartesianIndex(0, -1)
move(from::CartesianIndex, dir::RIGHT) = from + CartesianIndex(0, 1)
move(from::CartesianIndex, dir::UP) = from + CartesianIndex(-1, 0)
move(from::CartesianIndex, dir::DOWN) = from + CartesianIndex(1, 0)

function getmaze(start, maze, startingdir)
    total = 0
    direction = startingdir
    loc = move(start, direction)
    checkbounds(Bool, maze, loc) || (return -1)
    while maze[loc] != "S"
        total += 1
        direction = getfun[maze[loc]](flip(direction))
        direction == nothing && (return -1)
        loc = move(loc, direction)
        checkbounds(Bool, maze, loc) || (return -1)
    end
    return total
end

function getmaze(start, maze)
    for direction in (LEFT(), RIGHT(), UP(), DOWN())
        distance = getmaze(start, maze, direction)
        distance != -1 && (return distance)
    end
end

println(ceil(getmaze(start, maze)/2))

function getmazestart(start, maze)
    for direction in (LEFT(), RIGHT(), UP(), DOWN())
        distance = getmaze(start, maze, direction)
        distance != -1 && (return direction)
    end
end

function markmaze(start, maze)
    total = 0
    direction = getmazestart(start, maze)
    pieces = Set([start])
    loc = move(start, direction)
    while maze[loc] != "S"
        push!(pieces, loc)
        direction = getfun[maze[loc]](flip(direction))
        loc = move(loc, direction)
    end
    return pieces
end

function mazestructure(start, maze)
    total = 0
    direction = getmazestart(start, maze)
    structure = Set()
    loc = move(start, direction)
    push!(structure, ((start[1], start[2]), (loc[1], loc[2])))
    push!(structure, ((loc[1], loc[2]), (start[1], start[2])))
    while maze[loc] != "S"
        direction = getfun[maze[loc]](flip(direction))
        newloc = move(loc, direction)
        push!(structure, ((loc[1], loc[2]), (newloc[1], newloc[2])))
        push!(structure, ((newloc[1], newloc[2]), (loc[1], loc[2])))
        loc = newloc
    end
    return structure
end

move(from::CartesianIndex, dir::LEFT) = from + CartesianIndex(0, -1)

# function getinclusion(loc, maze, labels)
#     inside = 1 < loc[1] < size(maze)[1] && 1 < loc[2] < size(maze)[2]
#     if !inside
#         labels[loc] = -1
#         return
#     end
#     labels[loc] = 0
#     valid = 1
#     for direction in (LEFT(), RIGHT(), UP(), DOWN())
#         newloc = move(loc, direction)
#         if !(newloc in keys(labels))
#             getinclusion(newloc, maze, labels)
#         end
#         if labels[newloc] == -1
#             valid = -1
#             break
#         end
#     end
#     labels[loc] = valid
# end

# function getinclusion(start, maze)
#     mazepieces = markmaze(start, maze)
#     mazelabels = Dict{CartesianIndex{2}, Int}()
#     for piece in mazepieces
#         mazelabels[piece] = 1
#     end
#     while(length(mazelabels) != length(maze))
#         # println(length([x for x in values(mazelabels) if x]))
#         for i in 1:size(maze)[1]
#             for j in 1:size(maze)[2]
#                 loc = CartesianIndex(i, j)
#                 loc in keys(mazelabels) || getinclusion(loc, maze, mazelabels)
#             end
#         end
#     end
#     return mazelabels
#     # return length([x for x in values(mazelabels) if x == 1]) - length(mazepieces)
# end

function poisonr(loc, maze, poisoned)
    # loc == CartesianIndex(8, 6) && println("HERE")
    checkbounds(Bool, maze, loc) || return
    loc in poisoned && return
    push!(poisoned, loc)
    for direction in (LEFT(), RIGHT(), UP(), DOWN())
        newloc = move(loc, direction)
        poisonr(newloc, maze, poisoned)
    end
    for pair in ((LEFT(), UP()), (LEFT(),DOWN()), (RIGHT(), UP()), (RIGHT(), DOWN()))
        newloc = move(move(loc, pair[1]), pair[2])
        poisonr(newloc, maze, poisoned)
    end
end

function poison(start, maze)
    mazepieces = markmaze(start, maze)
    poisoned = Set{CartesianIndex{2}}(mazepieces)
    # checked = Set{CartesianIndex{2}}(mazepieces)
    for i in 1:size(maze)[1]
        loc = CartesianIndex(i, 1)
        poisonr(loc, maze, poisoned)
    end
    for i in 1:size(maze)[1]
        loc = CartesianIndex(i, size(maze)[2])
        poisonr(loc, maze, poisoned)
    end
    for i in 1:size(maze)[2]
        loc = CartesianIndex(size(maze)[1], i)
        poisonr(loc, maze, poisoned)
    end
    for i in 1:size(maze)[2]
        loc = CartesianIndex(1, i)
        poisonr(loc, maze, poisoned)
    end
    # return length(maze) - length(poisoned)
    return poisoned
end

function tryslip(corner, structure, corners, c, poisoned)
    test = CartesianIndex(2,2)
    up = CartesianIndex(corner[1]-1, corner[2])
    if checkbounds(Bool, c, up) && !(up in corners)
        between = ((corner[1], corner[2]), (corner[1], corner[2]+1))
        # println("up $between, $(between in structure)")
        # println(structure)
        if !(between in structure)
            # up == test && println("Up $between")
            push!(corners, up)
            tryslip(up, structure, corners, c, poisoned)
            push!(poisoned, CartesianIndex(between[1]))
            push!(poisoned, CartesianIndex(between[2]))
        end
    end
    down = CartesianIndex(corner[1]+1, corner[2])
    if checkbounds(Bool, c, down) && !(down in corners)
        between = ((corner[1]+1, corner[2]), (corner[1]+1, corner[2]+1))
        # println("down $between, $(between in structure)")
        if !(between in structure)
            # down == test && println("Down $between $corner")
            push!(corners, down)
            tryslip(down, structure, corners, c, poisoned)
            push!(poisoned, CartesianIndex(between[1]))
            push!(poisoned, CartesianIndex(between[2]))
        end
    end
    left = CartesianIndex(corner[1], corner[2]-1)
    if checkbounds(Bool, c, left) && !(left in corners)
        between = ((corner[1], corner[2]), (corner[1]+1, corner[2]))
        # println("left $between, $(between in structure)")
        if !(between in structure)
            # left == test && println("Left $between")
            push!(corners, left)
            tryslip(left, structure, corners, c, poisoned)
            push!(poisoned, CartesianIndex(between[1]))
            push!(poisoned, CartesianIndex(between[2]))
        end
    end
    right = CartesianIndex(corner[1], corner[2]+1)
    if checkbounds(Bool, c, right) && !(right in corners)
        between = ((corner[1], corner[2]+1), (corner[1]+1, corner[2]+1))
        # println("right $between, $(between in structure)")
        if !(between in structure)
            # right == test && println("Right $between $corner")
            push!(corners, right)
            tryslip(right, structure, corners, c, poisoned)
            push!(poisoned, CartesianIndex(between[1]))
            push!(poisoned, CartesianIndex(between[2]))
        end
    end
end

        

function poisonslip(start, maze)
    poisoned = poison(start, maze)
    structure = mazestructure(start, maze)
    mazepieces = markmaze(start, maze)
    corners = Set{CartesianIndex{2}}()
    c = fill(false, size(maze)[1]-1, size(maze)[2]-1)
    realpoisoned = setdiff(poisoned, mazepieces)
    for p in realpoisoned
        upleft = (p[1]-1, p[2]-1)
        downleft = (p[1], p[2]-1)
        upright = (p[1]-1, p[2])
        downright = (p[1], p[2])
        for (a,b) in [upleft, downleft, upright, downright]
            # checkbounds(Bool, corners, a, b) && (corners[a,b] = true)
            checkbounds(Bool, c, a, b) && push!(corners, CartesianIndex(a,b))
        end
    end
    startingcorners = copy(corners)
    # println(length(poisoned))
    for corner in startingcorners
        tryslip(corner, structure, corners, c, poisoned)
    end
    # println(length(poisoned))
    # for corner in corners
    #     push!(poisoned, corner)
    #     push!(poisoned, CartesianIndex(corner[1]+1, corner[2]))
    #     push!(poisoned, CartesianIndex(corner[1]+1, corner[2]+1))
    #     push!(poisoned, CartesianIndex(corner[1], corner[2]+1))
    # end
    # return poisoned
    return length(maze) - length(poisoned)
end

println(poisonslip(start,maze))
# poisoned = poison(start, maze)
# pmaze = copy(maze)
# for p in poisoned
#     pmaze[p] = "P"
# end
# println(pmaze)