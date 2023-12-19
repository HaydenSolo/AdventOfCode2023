include("utils.jl")

part2 = true
input = readinput()


function getline(line, part2)
    amount = 0
    dir = "U"
    if part2
        a, b, hex = split(line)
        amount = parse(Int, hex[3:end-2], base=16)
        dirdict = Dict('0'=>"R", '1'=>"D", '2'=>"L", '3'=>"U")
        dir = dirdict[hex[end-1]]
    else
        dir, amount, _ = split(line)
        amount = parseint(amount)
    end
    return dir, amount
end

function getdimensions(line)
    dir, amount = getline(line, part2)
    if dir == "D" return [amount, 0]
    elseif dir == "U" return [-amount, 0]
    elseif dir == "R" return [0, amount]
    elseif dir == "L" return [0, -amount]
    end
end

function getgrid(input)
    dims = getdimensions.(input)
    dims[1] = dims[1] + start
    for i in 2:length(dims)
        dims[i] = dims[i] + dims[i-1]
    end
    maxrow = maxcol = typemin(Int)
    minrow = mincol = typemax(Int)
    for (row, col) in dims
        row > maxrow && (maxrow = row)
        row < minrow && (minrow = row)
        col > maxcol && (maxcol = col)
        col < mincol && (mincol = col)
    end
    rows = maxrow - minrow + 1
    cols = maxcol - mincol + 1
    startrow = 2 - minrow
    startcol = 2 - mincol
    # rows, cols = maximum(dims) - minimum(dims) + [1,1]
    # println("$rows, $cols, $startrow, $startcol")
    rows, cols, startrow, startcol
end

function dig(grid, row, col, dir, amount)
    amount == 0 && return (row, col)
    push!(grid, (row, col))
    if dir == "D" row += 1
    elseif dir == "U" row -= 1
    elseif dir == "R" col += 1
    elseif dir == "L" col -= 1
    end
    dig(grid, row, col, dir, amount-1)
end


function dig(grid, row, col, line)
    dir, amount = getline(line, part2)
    # println("$dir, $amount")
    dig(grid, row, col, dir, amount)
end

function diggrid(input)
    rows, cols, row, col = getgrid(input)
    # row = col = 1
    grid = Set{Tuple{Int, Int}}()
    for line in input
        dir, amount = getline(line, part2)
        while amount > 0
            push!(grid, (row, col))
            if dir == "D" row += 1
            elseif dir == "U" row -= 1
            elseif dir == "R" col += 1
            elseif dir == "L" col -= 1
            end
            amount -= 1
        end
    end
    grid, rows, cols
end

function fillsquare(grid, rows, cols, row, col, ignore)
    ((row, col) in grid || (row, col) in ignore) && return
    push!(ignore, (row, col))
    row > 1 && fillsquare(grid, rows, cols, row-1, col, ignore)
    row < rows && fillsquare(grid, rows, cols, row+1, col, ignore)
    col > 1 && fillsquare(grid, rows, cols, row, col-1, ignore)
    col < cols && fillsquare(grid, rows, cols, row, col+1, ignore)
end

function fillgrid(input)
    grid, rows, cols = diggrid(input)
    ignore = Set{Tuple{Int, Int}}()
    tocheck = Set{Tuple{Int, Int}}()
    for row in 1:rows push!(tocheck, (row, 1)) end
    for row in 1:rows push!(tocheck, (row, cols)) end
    for col in 1:cols push!(tocheck, (1, col)) end
    for col in 1:cols push!(tocheck, (rows, col)) end
    while !isempty(tocheck)
        # println(length(tocheck))
        row, col = pop!(tocheck)
        ((row, col) in grid || (row, col) in ignore) && continue
        push!(ignore, (row, col))
        row > 1 && push!(tocheck, (row-1, col))
        row < rows && push!(tocheck, (row+1, col))
        col > 1 && push!(tocheck, (row, col-1))
        col < cols && push!(tocheck, (row, col+1))
    end
    return rows*cols - length(ignore)
end

# println(sum(fillgrid(input)))
function main(input)
    answer = fillgrid(input)
    println(answer)
    open("resultlog.txt", "w") do io
        println(io, answer)
    end
end

main(input)