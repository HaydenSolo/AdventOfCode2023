include("utils.jl")

input = split.(readinput())

function checkline(checking, answers; finalpass=false)
    # println(checking)
    matches = [length(match.match) for match in eachmatch(r"#+", checking)]

    isempty(matches) && !finalpass && (return true)
    if finalpass
        length(matches) == length(answers) || (return false)
    end
    length(matches) > length(answers) && (return false)
    checkedanswers = answers[1:length(matches)]
    matches[1:end-1] == checkedanswers[1:end-1] || (return false)
    (finalpass ? matches[end] == checkedanswers[end] : matches[end] <= checkedanswers[end]) || (return false)

    # length(lens) == length(info) && println("$info $lens")
    return true
end

# function getpossibilities(len, needed, record, info)
#     level = [""]
#     for i in 1:len
#         println("$i $(length(level))")
#         new = String[]
#         for l in level
#             if count(==('#'), l) < needed
#                 push!(new, l*"#")
#             end
#             push!(new, l*".")
#         end
#         level = new
#     end
#     filter(p -> count(==('#'), p) == needed, level)
# end

function buildstring(record, replacers; unknown=nothing)
    unknown == nothing && (unknown = findall(isequal('?'), record))
    current = 1
    io = IOBuffer()
    for (i, c) in enumerate(record)
        if current <= length(replacers) && i in unknown
            print(io, replacers[current])
            current += 1
        else
            print(io, c)
        end
    end
    String(take!(io))
end

function recbuild(record, unknown, needed, answers, current, acc; io=Base.stdout, depth=1)
    if length(current) == length(unknown)
        checkline(buildstring(record, current; unknown=unknown), answers; finalpass=true) && push!(acc, current)
        return
    end
    un = unknown[depth]
    shortened = record[1:un]
    remaining = unknown[depth+1:end]
    for symbol in ("#", ".")
        replacers = current * symbol
        c = count(isequal('#'), replacers)
        c > needed && continue
        # println("With $replacers $c #, $(length(remaining)) remaining, $needed needed")
        c + length(remaining) < needed && continue
        newstring = buildstring(shortened, replacers; unknown=unknown)
        checkline(newstring, answers) && recbuild(record, unknown, needed, answers, replacers, acc; io=io, depth=depth+1)
    end
end

function buildanswersrec(record, info; io=Base.stdout)
    unknown = findall(isequal('?'), record)
    needed = sum(parseint(split(info, ","))) - count(==('#'), record)
    answers = parseint(split(info, ","))
    acc = []
    recbuild(record, unknown, needed, answers, "", acc; io=io)
    return length(acc)
end


function buildanswers(record, info; io=Base.stdout)
    unknown = findall(isequal('?'), record)
    needed = sum(parseint(split(info, ","))) - count(==('#'), record)
    answers = parseint(split(info, ","))
    level = [""]
    # print(io, "Need to find $(length(unknown)) values. ")
    for (i, un) in enumerate(unknown)
        # print(io, "Level $i: ")
        new = String[]
        shortened = record[1:un]
        remaining = unknown[i+1:end]
        for l in level
            for symbol in ("#", ".")
                replacers = l * symbol
                c = count(isequal('#'), replacers)
                c > needed && continue
                # println("With $replacers $c #, $(length(remaining)) remaining, $needed needed")
                c + length(remaining) < needed && continue
                newstring = buildstring(shortened, replacers; unknown=unknown)
                checkline(newstring, answers) && push!(new, replacers)
            end
        end
        # print(io, "$(length(new)). ")
        level = new
    end
    # println(io)
    # println("Pre-final size of $(length(level))")
    final = [l for l in level if checkline(buildstring(record, l; unknown=unknown), answers; finalpass=true)]
    # println("Post-final size of $(length(final))")
    # println(final)
    return length(final)
end

        #             if count(==('#'), l) < needed
        #                 push!(new, l*"#")
        #             end
        #             push!(new, l*".")
        #         end
        #         level = new
        #     end
        #     filter(p -> count(==('#'), p) == needed, level)

function getdamaged(line; io=Base.stdout)
    record, info = line
    record = repeat(record*"?", 5)[1:end-1]
    info = repeat(info*",", 5)[1:end-1]
    return buildanswersrec(record, info; io=io)
    # unknown = findall(isequal('?'), record)
    # needed = sum(parseint(split(info, ","))) - count(==('#'), record)
    # options = append!(['#' for _ in 1:length(unknown)], ['.' for _ in 1:length(unknown)])
    # possibilities = getpossibilities(length(unknown), needed)
    # println(length(possibilities))
    # correct = 0
    # for possibility in possibilities
    #     current = 1
    #     io = IOBuffer()
    #     for (i, c) in enumerate(record)
    #         if i in unknown
    #             print(io, possibility[current])
    #             current += 1
    #         else
    #             print(io, c)
    #         end
    #     end
    #     checking = String(take!(io))
    #     checkline(checking, info) && (correct += 1)
    # end
    return correct
end

# println(getdamaged(input[1]))
function main(pos)
# total = 0
# results = [0 for _ in 1:length(input)]
# for (i, line) in enumerate(input)
#     dam = getdamaged(line)
#     # total += dam
#     results[i] = dam
#     println("Completed $i, added $dam")
# end
# # println(total)
# println(sum(results))
    broken = parseint(readlines("broken.txt"))
    linenum = broken[pos]
    open("cheekyresults/$linenum.txt","w") do io
        println(io, "Starting running")
        line = input[linenum]
        dam = getdamaged(line; io=io)
        println(io, dam)
    end
end

function main()
    total = 0
    results = [0 for _ in 1:length(input)]
    for (i, line) in enumerate(input)
        dam = getdamaged(line)
        # total += dam
        results[i] = dam
        println("Completed $i, added $dam")
    end
    # println(total)
    println(sum(results))
end
# main()
if abspath(PROGRAM_FILE) == @__FILE__
    length(ARGS) == 0 ? main(1) : main(parseint(ARGS[1]))
end
