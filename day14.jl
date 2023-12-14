include("utils.jl")

input = readmatrix()

function movenorthcol(column)
    total = 0
    adding = length(column)
    for (i, val) in enumerate(column)
        if val == "O"
            total += adding
            adding -= 1
        end
        val == "#" && (adding = length(column)-i)
    end
    return total
end

function tomat(vecs)
    input = hcat(vecs...)
end

function tomatflip(vecs)
    input = hcat(vecs...)
    flip = similar(input, String, size(input)[2], size(input)[1])
    for i in 1:size(input)[1]
        for j in 1:size(input)[2]
            flip[j, i] = input[i, j]
        end
    end
    flip
end


function north(column)
    adding = length(column)
    positions = Int[]
    for (i, val) in enumerate(column)
        if val == "O"
            push!(positions, adding)
            adding -= 1
        end
        val == "#" && (adding = length(column)-i)
    end
    len = length(column) + 1
    newrocks = len .- positions
    
    return [i in newrocks ? "O" : (v == "O" ? "." : v)  for (i, v) in enumerate(column)]
end
north(mat::Matrix) = tomat(north.(eachcol(mat)))

function south(column)
    adding = 1
    positions = Int[]
    for (i, val) in enumerate(reverse(column))
        if val == "O"
            push!(positions, adding)
            adding += 1
        end
        val == "#" && (adding = i+1)
    end
    len = length(column) + 1
    # println(positions)
    newrocks = len .- positions
    
    return [i in newrocks ? "O" : (v == "O" ? "." : v)  for (i, v) in enumerate(column)]
end
south(mat::Matrix) = tomat(south.(eachcol(mat)))

function west(row)
    adding = length(row)
    positions = Int[]
    for (i, val) in enumerate(row)
        if val == "O"
            push!(positions, adding)
            adding -= 1
        end
        val == "#" && (adding = length(row)-i)
    end
    len = length(row) + 1
    newrocks = len .- positions
    
    return [i in newrocks ? "O" : (v == "O" ? "." : v)  for (i, v) in enumerate(row)]
end
west(mat::Matrix) = tomatflip(west.(eachrow(mat)))

function east(row)
    adding = 1
    positions = Int[]
    for (i, val) in enumerate(reverse(row))
        if val == "O"
            push!(positions, adding)
            adding += 1
        end
        val == "#" && (adding = i+1)
    end
    len = length(row) + 1
    # println(positions)
    newrocks = len .- positions
    
    return [i in newrocks ? "O" : (v == "O" ? "." : v)  for (i, v) in enumerate(row)]
end
east(mat::Matrix) = tomatflip(east.(eachrow(mat)))

cycle(mat::Matrix) =  mat |> north |> west |> south |> east

function findrepeat(mat::Matrix)
    repeats = Vector()
    push!(repeats, mat)
    next = cycle(mat)
    while next ∉ repeats
        push!(repeats, next)
        next = cycle(next)
    end
    for (i,v) in enumerate(repeats)
        v == next && return (length(repeats), length(repeats)-i, next)
    end
    # println(length(repeats))
end

function getp2(mat::Matrix; cycles=1000000000)
    start, every, next = findrepeat(mat)
    println("Start: $start Every: $every")
    togo = (cycles-start)%(every+1)
    for i in 1:togo
        next = cycle(next)
    end
    return next
end

function getload(mat::Matrix)
    total = 0
    en = size(mat)[1] + 1
    for (i,row) in enumerate(eachrow(mat))
        total += count(isequal("O"), row) * (en - i)
    end
    total
end

println(getload(getp2(input)))

function repeat(mat::Matrix, cycles::Int)
    for i in 1:cycles
        mat = cycle(mat)
    end
    mat
end