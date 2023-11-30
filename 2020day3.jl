input = readinput()
data = hcat(split.(input, "")...)

pos = [1,1]

trees = 0

while pos[2] <= size(data)[2] - 1
    pos[1] = pos[1] + 3 <= size(data)[1] ? pos[1] + 3 : pos[1] + 3 - size(data)[1]
    pos[2] = pos[2] + 1
    trees += data[pos[1], pos[2]] == "#" ? 1 : 0
end

println(trees)

function checkslope(right, down)
    pos = [1,1]
    trees = 0
    while pos[2] <= size(data)[2] - 1
        pos[1] = pos[1] + right <= size(data)[1] ? pos[1] + right : pos[1] + right - size(data)[1]
        pos[2] = pos[2] + down
        trees += data[pos[1], pos[2]] == "#" ? 1 : 0
    end
    return trees
end

res = [checkslope(1,1), checkslope(3,1), checkslope(5,1), checkslope(7,1), checkslope(1,2)]
println(prod(res))