include("utils.jl")

input = read("input.txt", String)
groups = split(input, "\n\n")

struct A2B
    from::Int
    to::Int
    count::Int
end

function a2b(data)
    a2bs = A2B[]
    for line in split(data, "\n")[2:end]
        vals = split(line)
        newa2b = A2B(parseint(vals[2]), parseint(vals[1]), parseint(vals[3]))
        push!(a2bs, newa2b)
    end
    return a2bs
end

function getfroma2bs(a2bs, val)
    for relationship in a2bs
        if relationship.from <= val < relationship.from + relationship.count
            return relationship.to + (val - relationship.from)
        end
    end
    return val
end


seed2soil = a2b(groups[2])
soil2fertilizer = a2b(groups[3])
fertilizer2water = a2b(groups[4])
water2light = a2b(groups[5])
light2temperature = a2b(groups[6])
temperature2humidity = a2b(groups[7])
humidity2location = a2b(groups[8])

seeds = parseint(split(groups[1][8:end]))
seed2location = [getfroma2bs(humidity2location, getfroma2bs(temperature2humidity, getfroma2bs(light2temperature, getfroma2bs(water2light, getfroma2bs(fertilizer2water, getfroma2bs(soil2fertilizer, getfroma2bs(seed2soil, seed))))))) for seed in seeds]
println(minimum(seed2location))

seedpairs = parseint(split(groups[1][8:end]))
ranges = [(from, count) for (from, count) in zip(seedpairs[1:2:end], seedpairs[2:2:end])]

minsofar = getfroma2bs(humidity2location, getfroma2bs(temperature2humidity, getfroma2bs(light2temperature, getfroma2bs(water2light, getfroma2bs(fertilizer2water, getfroma2bs(soil2fertilizer, getfroma2bs(seed2soil, seeds[1])))))))
for r in ranges
    println(r)
    for i in r[1]:r[1]+r[2]-1
        found = getfroma2bs(humidity2location, getfroma2bs(temperature2humidity, getfroma2bs(light2temperature, getfroma2bs(water2light, getfroma2bs(fertilizer2water, getfroma2bs(soil2fertilizer, getfroma2bs(seed2soil, i)))))))
        if found < minsofar
            minsofar = found
        end
    end
end
println(minsofar)