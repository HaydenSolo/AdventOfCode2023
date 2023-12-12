readinput(test::Bool=false) = test ? readlines("test.txt") : readlines("input.txt")

parseint(s::AbstractString) = parse(Int64, s)
parsefloat(s::AbstractString) = parse(Float64, s)

parseint(ss) = parseint.(ss)
parsefloat(ss) = parsefloat.(ss)

maketypes(types...) = foreach(t -> eval(:(struct $(Symbol(t)) end)), types)

function readmatrix(test::Bool=false)
    input = String.(hcat(split.(readinput(test), "")...))
    flip = similar(input, String, size(input)[2], size(input)[1])
    for i in 1:size(input)[1]
        for j in 1:size(input)[2]
            flip[j, i] = input[i, j]
        end
    end
    flip
end