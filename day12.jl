include("utils.jl")

input = split.(readinput())

function checkline(checking, info)
    matches = [length(match.match) for match in eachmatch(r"#+", checking)]
    lens = join(matches, ",")
    return lens == info
end

function getpossibilities(len, needed)
    level = [""]
    for i in 1:len
        new = String[]
        for l in level
            if count(==('#'), l) < needed
                push!(new, l*"#")
            end
            push!(new, l*".")
        end
        level = new
    end
    filter(p -> count(==('#'), p) == needed, level)
end

function getdamaged(line)
    record, info = line
    unknown = findall(isequal('?'), record)
    needed = sum(parseint(split(info, ","))) - count(==('#'), record)
    possibilities = getpossibilities(length(unknown), needed)
    correct = 0
    for possibility in possibilities
        current = 1
        io = IOBuffer()
        for (i, c) in enumerate(record)
            if i in unknown
                print(io, possibility[current])
                current += 1
            else
                print(io, c)
            end
        end
        checking = String(take!(io))
        checkline(checking, info) && (correct += 1)
    end
    return correct
end

function main()
    open("answers.txt","w") do io
        total = 0
        for (i, line) in enumerate(input)
            dam = getdamaged(line)
            println(io, dam)
            total += dam
            println("Completed $i")
        end
        println(total)
    end
end
main()