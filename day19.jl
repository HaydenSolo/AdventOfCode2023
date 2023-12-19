include("utils.jl")

input = readinput()

struct Rule
    rule::Expr
    result::AbstractString
end
function Rule(line::AbstractString)
    rulestr, result = split(line, ":")
    rule = Meta.parse(rulestr)
    Rule(rule, result)
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

function test(rules::Rules)
    for rule in rules.rules
        eval(rule.rule) && (return rule.result)
    end
    return rules.default
end

function testline(line, rules)
    vals = split(match(r"{(.+)}", line).captures[1], ",")
    for val in vals
        eval(Meta.parse(val))
    end
    current = rules["in"]
    while true
        res = test(current)
        res == "R" && (return 0)
        res == "A" && (return sum(parseint([match.match for match in eachmatch(r"\d+", line)])))
        current = rules[res]
    end
end

function main(input)
    rules = getrules(input)
    middle = findfirst(==(""), input)
    results = testline.(input[middle+1:end], Ref(rules))
    sum(results)
end

println(main(input))