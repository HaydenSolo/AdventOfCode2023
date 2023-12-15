include("utils.jl")

input = split(readinput()[1], ",")

function dohash(str)
    total = 0
    for char in str
        ascii = Int(char)
        total += ascii
        total *= 17
        total %= 256
    end
    return total
end

println(sum(dohash.(input)))

mutable struct Lens
    key::AbstractString
    focal::Int
end

boxes = [Lens[] for i in 1:256]

function remove(str, boxes)
    label = str[1:end-1]
    key = dohash(label)+1
    boxes[key] = [lens for lens in boxes[key] if lens.key != label]
end



function fillbox(str, boxes)
    if str[end] == '-' 
        remove(str, boxes)
        return
    end
    label = str[1:end-2]
    len = parseint(str[end:end])
    key = dohash(label)+1
    changed = false
    for lens in boxes[key]
        if lens.key == label
            lens.focal = len
            changed = true
        end
    end
    changed || push!(boxes[key], Lens(label, len))
end

fillbox.(input, Ref(boxes))

function getpower(boxes)
    total = 0
    for (i, box) in enumerate(boxes)
        for (j, lens) in enumerate(box)
            boxnum = i
            slot = j
            focal = lens.focal
            total += boxnum*slot*focal
        end
    end
    total
end

println(getpower(boxes))