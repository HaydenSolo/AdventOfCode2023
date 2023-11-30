readinput(test::Bool=false) = test ? readlines("test.txt") : readlines("input.txt")

parseint(s::AbstractString) = parse(Int64, s)
parsefloat(s::AbstractString) = parse(Float64, s)

parseint(ss) = parseint.(ss)
parsefloat(ss) = parsefloat.(ss)

maketypes(types...) = foreach(t -> eval(:(struct $(Symbol(t)) end)), types)