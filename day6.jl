include("utils.jl")

input = readinput()

struct Race
    time::Int
    distance::Int
end

times = parseint([match.match for match in eachmatch(r"\d+", input[1])])
distances = parseint([match.match for match in eachmatch(r"\d+", input[2])])
races = [Race(z...) for z in zip(times, distances)]

function checkrace(race::Race)
    gooddistances = Int[]
    for time in 1:race.time-1
        timeremaining = race.time - time
        distance = timeremaining * time
        distance > race.distance && push!(gooddistances, distance)
    end
    return length(gooddistances)
end

winning = checkrace.(races)
println(prod(winning))

totaltime = parseint(join([match.match for match in eachmatch(r"\d+", input[1])], ""))
totaldistance = parseint(join([match.match for match in eachmatch(r"\d+", input[2])], ""))
totalrace = Race(totaltime, totaldistance)
println(checkrace(totalrace))