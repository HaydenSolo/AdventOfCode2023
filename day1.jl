include("utils.jl")

input = readinput()

function getval(x) 
    s = replace(x, r"[a-zA-Z]"=>"")
    parseint("$(s[1])$(s[end])")
end

alllines = getval.(input)
println(sum(alllines))

function getval2(txt)
    pat = r"one|two|three|four|five|six|seven|eight|nine|[0-9]"
    words = [ match.match for match in eachmatch(pat, txt; overlap=true)]
    parser = Dict(
        "one"=>"1",
        "two"=>"2",
        "three"=>"3",
        "four"=>"4",
        "five"=>"5",
        "six"=>"6",
        "seven"=>"7",
        "eight"=>"8",
        "nine"=>"9",
    )
    word1 = words[1]
    word2 = words[end]
    occursin(word1, "123456789") || (word1 = parser[word1])
    occursin(word2, "123456789") || (word2 = parser[word2])
    parseint("$(word1)$(word2)")
end

alllines = getval2.(input)
println(sum(alllines))