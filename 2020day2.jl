input = readinput()

function testline(line)
    data = split(line)
    first, second = split(data[1], "-")
    firstn = parseint(first)
    secondn = parseint(second)
    letter = data[2][1]
    test = 0
    data[3][firstn] == letter && (test += 1)
    data[3][secondn] == letter && (test += 1)
    return test == 1 ? 1 : 0
end

println(sum(testline.(input)))