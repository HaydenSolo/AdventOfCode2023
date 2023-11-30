input = read("input.txt", String)
passports = split(input, "\n\n")

function simplevalid(passport)
    needed = ["ecl", "pid", "eyr", "byr", "iyr", "hgt", "hcl"]
    return occursin.(needed, passport) |> all
end

validpasses = simplevalid.(passports)
println(sum(validpasses))



function valid(passport)
    simplevalid(passport) || (return false)
    rules = Dict(
        "byr" => s -> 1920 <= parseint(s) <= 2002,
        "iyr" => s -> 2010 <= parseint(s) <= 2020,
        "eyr" => s -> 2020 <= parseint(s) <= 2030,
        "hcl" => s -> s[1] == '#' && length(s) == 7 && all(occursin.(split(s[2:end],""), Ref("0123456789abcdef"))),
        "ecl" => s -> s in ("amb", "blu", "brn", "gry", "grn", "hzl", "oth"),
        "pid" => s -> replace(s, r"\d\d\d\d\d\d\d\d\d" => "") == "",
        "hgt" => s -> s[end-1:end] in ("cm", "in") ? (s[end-1:end] == "cm" ? 150 <= parseint(s[1:end-2]) <= 193 : 59 <= parseint(s[1:end-2]) <= 76) : false,
    )
    pairs = split.(split(passport), ":")
    for pair in pairs
        try
        if pair[1] in keys(rules)
            rules[pair[1]](pair[2]) || (return false)
        end
        catch
            println(pair)
        end
    end
    true
end

validpasses = valid.(passports)
println(sum(validpasses))
