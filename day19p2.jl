include("utils.jl")

input = readinput()

struct Range
    x::Tuple{Int, Int}
    m::Tuple{Int, Int}
    a::Tuple{Int, Int}
    s::Tuple{Int, Int}
end
Range() = Range((1, 4000), (1, 4000), (1, 4000), (1, 4000))
function Range(range::Range; x=nothing, m=nothing, a=nothing, s=nothing)
    x == nothing && (x = range.x)
    m == nothing && (m = range.m)
    a == nothing && (a = range.a)
    s == nothing && (s = range.s)
    Range(x, m, a, s)
end
Base.show(io::IO, z::Range) = print(io, "x=$(z.x) m=$(z.m) a=$(z.a) s=$(z.s)")

abstract type Rule end

struct XRule <: Rule
    gt::Bool
    val::Int
    result::AbstractString
end

struct MRule <: Rule
    gt::Bool
    val::Int
    result::AbstractString
end

struct ARule <: Rule
    gt::Bool
    val::Int
    result::AbstractString
end

struct SRule <: Rule
    gt::Bool
    val::Int
    result::AbstractString
end

function Rule(line::AbstractString)
    rulestr, result = split(line, ":")
    gt = '>' in rulestr
    letter, val = split(rulestr, r"[<>]")
    val = parseint(val)
    dispatch = Dict("a"=>ARule, "x"=>XRule, "m"=>MRule, "s"=>SRule)[letter]
    dispatch(gt, val, result)
end

struct Rules
    name::AbstractString
    rules::Vector{Rule}
    default::AbstractString
end
function Rules(line::AbstractString)
    name = match(r".+(?={)", line).match
    rules = split(match(r"{(.+)}", line).captures[1], ",")
    default = rules[end]
    savedrules = [Rule(str) for str in rules[1:end-1]]
    Rules(name, savedrules, default)
end

function getrules(input)
    rules = Rules[]
    for line in input
        line == "" && (return Dict([rule.name=>rule for rule in rules]))
        push!(rules, Rules(line))
    end
    Dict([rule.name=>rule for rule in rules])
end

getrange(rule::XRule, range::Range) = range.x
getrange(rule::MRule, range::Range) = range.m
getrange(rule::ARule, range::Range) = range.a
getrange(rule::SRule, range::Range) = range.s

getcombinations(range::Range) = (range.x[2] - range.x[1] + 1) * (range.m[2] - range.m[1] + 1) * (range.a[2] - range.a[1] + 1) * (range.s[2] - range.s[1] + 1)

Range(range::Range, rule::XRule, newvals::Tuple{Int, Int}) = Range(newvals, range.m, range.a, range.s)
Range(range::Range, rule::MRule, newvals::Tuple{Int, Int}) = Range(range.x, newvals, range.a, range.s)
Range(range::Range, rule::ARule, newvals::Tuple{Int, Int}) = Range(range.x, range.m, newvals, range.s)
Range(range::Range, rule::SRule, newvals::Tuple{Int, Int}) = Range(range.x, range.m, range.a, newvals)

function getcombinations(rule::AbstractString, range::Range, ruledict::Dict)
    rule == "R" && (return 0)
    rule == "A" && (return getcombinations(range))
    return getcombinations(ruledict[rule], range, ruledict) 
end
    
function getcombinations(rule::Rule, range::Range, ruledict::Dict)
    observedrange = getrange(rule, range)
    if rule.gt
        observedrange[2] <= rule.val && (return 0, range)
        observedrange[1] > rule.val && (return getcombinations(range), nothing)
        matching = (rule.val+1, observedrange[2])
        notmatching = (observedrange[1], rule.val)
        matchingrange = Range(range, rule, matching)
        notmatchingrange = Range(range, rule, notmatching)
        return getcombinations(rule.result, matchingrange, ruledict), notmatchingrange
    else
        observedrange[1] >= rule.val && (return 0, range)
        observedrange[2] < rule.val && (return getcombinations(range), nothing)
        matching = (observedrange[1], rule.val-1)
        notmatching = (rule.val, observedrange[2])
        matchingrange = Range(range, rule, matching)
        notmatchingrange = Range(range, rule, notmatching)
        return getcombinations(rule.result, matchingrange, ruledict), notmatchingrange
    end
end

function getcombinations(rules::Rules, range::Range, ruledict::Dict)
    totalcombinations = 0
    for rule in rules.rules
        combinations, range = getcombinations(rule, range, ruledict)
        totalcombinations += combinations
        range == nothing && (return combinations)
    end
    return totalcombinations + getcombinations(rules.default, range, ruledict)
end
function getcombinations(rules::Dict, range::Range)
    baserules = rules["in"]
    getcombinations(baserules, range, rules)
end
getcombinations(rules::Dict) = getcombinations(rules, Range())

function main(input)
    rules = getrules(input)
    combinations = getcombinations(rules)
end

println(main(input))