include("utils.jl")

function getdata()
    input = readinput()
    gaps = append!(append!([0], [i for i in 1:length(input) if input[i] == ""]), [length(input)+1])
    maps = Matrix{String}[]
    for (i, j) in zip(gaps[1:end-1], gaps[2:end])
        lines = input[i+1:j-1]
        map = String.(hcat(split.(lines, "")...))
        flip = similar(map, String, size(map)[2], size(map)[1])
        for i in 1:size(map)[1]
            for j in 1:size(map)[2]
                flip[j, i] = map[i, j]
            end
        end
        push!(maps,flip)
    end
    maps
end

data = getdata()

function checkverticalreflection(map, hole)
    movement = 1
    distance = min(hole, size(map)[2]-hole)
    while movement <= distance
        left = map[:, hole-movement+1]
        right = map[:, hole+movement]
        left == right || (return false)
        movement += 1
    end
    return true
end

function findvertical(map)
    holes = size(map)[2]-1
    for hole in 1:holes
        checkverticalreflection(map, hole) && (return hole)
    end
    return 0
end

function checkhorizontalreflection(map, hole)
    movement = 1
    distance = min(hole, size(map)[1]-hole)
    while movement <= distance
        left = map[hole-movement+1, :]
        right = map[hole+movement, :]
        left == right || (return false)
        movement += 1
    end
    return true
end

function findhorizontal(map)
    holes = size(map)[1]-1
    for hole in 1:holes
        checkhorizontalreflection(map, hole) && (return hole)
    end
    return 0
end

res = [findvertical(map) + 100*findhorizontal(map) for map in data]
println(sum(res))

function fuzzyequal(left::Vector, right::Vector; allowances=1)
    starting = allowances
    for (l, r) in zip(left, right)
        if l != r
            allowances == 0 && (return :false)
            allowances -= 1
        end
    end
    return starting == allowances ? :true : :fuzzy
end

function checkhorizontalreflectionp2(map, hole)
    movement = 1
    distance = min(hole, size(map)[1]-hole)
    usedallowance = false
    while movement <= distance
        left = map[hole-movement+1, :]
        right = map[hole+movement, :]
        eq = fuzzyequal(left, right)
        eq == :false && (return false)
        if eq == :fuzzy
            usedallowance == true && (return false)
            usedallowance = true
        end
        movement += 1
    end
    return true
end

function findhorizontalp2(map)
    original = findhorizontal(map)
    holes = size(map)[1]-1
    for hole in 1:holes
        hole == original && continue
        checkhorizontalreflectionp2(map, hole) && (return hole)
    end
    return 0
end

function checkverticalreflectionp2(map, hole)
    movement = 1
    distance = min(hole, size(map)[2]-hole)
    usedallowance = false
    while movement <= distance
        left = map[:, hole-movement+1]
        right = map[:, hole+movement]
        eq = fuzzyequal(left, right)
        eq == :false && (return false)
        if eq == :fuzzy
            usedallowance == true && (return false)
            usedallowance = true
        end
        movement += 1
    end
    return true
end

function findverticalp2(map)
    original = findvertical(map)
    holes = size(map)[2]-1
    for hole in 1:holes
        hole == original && continue
        checkverticalreflectionp2(map, hole) && (return hole)
    end
    return 0
end

res = [findverticalp2(map) + 100*findhorizontalp2(map) for map in data]
println(sum(res))