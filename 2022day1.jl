data = readinput()

mutable struct Elf
    calories::Int64
end
calories(e::Elf) = e.calories

elves = Elf[Elf(0)]
for i in data
    if i == ""
        push!(elves, Elf(0))
    else
        elves[end].calories += parseint(i)
    end
end

most = maximum(calories.(elves))
println(most)

s = sort(calories.(elves))
println(sum(s[end-2:end]))