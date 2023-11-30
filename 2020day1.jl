input = parseint(readinput())

for (i, dat) in enumerate(input)
    for (j, dat2) in enumerate(input[i+1:end])
        for k in input[i+1:end][j+1:end]
            dat + dat2 + k == 2020 && println(dat * dat2 * k)
        end
    end
end