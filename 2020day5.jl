include("utils.jl")

input = readinput()

testlin = "FBFBBFFRLR"

function getlocation(line, minloc=0, maxloc=127)
    if minloc == maxloc
        return minloc
    end
    range = maxloc-minloc
    newrule = line[1]
    halfway = minloc + range/2
    if newrule == 'F' || newrule == 'L'
        return getlocation(line[2:end], minloc, floor(halfway))
    else
        return getlocation(line[2:end], ceil(halfway), maxloc)
    end
end


function getid(line)
    row = getlocation(line)
    col = getlocation(line[8:end], 0, 7)
    return Int(row*8 + col)
end

function getid2(line)
    line = replace(line, r"[FL]"=>"0")
    line = replace(line, r"[BR]"=>"1")
    rowline = line[1:7]
    colline = line[8:end]
    row = parse(Int, rowline; base=2)
    col = parse(Int, colline; base=2)
    return row*8+col
end

ids = getid2.(input)

println(maximum(ids))

allseats = sort(ids)
for seat in allseats
    if !(seat+1 in allseats)
        println(seat+1)
        break
    end
end