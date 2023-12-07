include("utils.jl")
using DataStructures

input = readinput()

cardorder = Dict('A'=>1, 'K'=>2, 'Q'=>3, 'J'=>4, 'T'=>5, '9'=>6, '8'=>7, '7'=>8, '6'=>9, '5'=>10, '4'=>11, '3'=>12, '2'=>13)

fiveofkind(hand) = 5 in values(hand)
fourofkind(hand) = 4 in values(hand)
fullhouse(hand) = 3 in values(hand) && 2 in values(hand)
threeofkind(hand) = 3 in values(hand)
twopair(hand) = counter(values(hand))[2] == 2
onepair(hand) = 2 in values(hand)

function gethand(line)
    hand = counter(split(line)[1])
    first = 7
    if fiveofkind(hand)
        first = 1
    elseif fourofkind(hand)
        first = 2
    elseif fullhouse(hand)
        first = 3
    elseif threeofkind(hand)
        first = 4
    elseif twopair(hand)
        first = 5
    elseif onepair(hand)
        first = 6
    end
    rankings = append!([first], [cardorder[c] for c in split(line)[1]])
    return rankings
end

hands = gethand.(input)
sorted = sortperm(hands; rev=true)

getbid(hand) = parseint(split(hand)[2])
bids = getbid.(input)

println(sum(bids[sorted] .* Vector(1:length(input))))

cardorder = Dict('A'=>1, 'K'=>2, 'Q'=>3, 'J'=>14, 'T'=>5, '9'=>6, '8'=>7, '7'=>8, '6'=>9, '5'=>10, '4'=>11, '3'=>12, '2'=>13)
fiveofkind(hand) = 5 in values(hand) || (4 in values(hand) && hand['J'] == 1) || (3 in values(hand) && hand['J'] == 2) || (2 in values(hand) && hand['J'] == 3) || (1 in values(hand) && hand['J'] == 4)
fourofkind(hand) = 4 in values(hand) || (3 in values(hand) && hand['J'] == 1) || (1 in values(hand) && hand['J'] == 3) || (2 in values(hand) && hand['J'] == 2 && counter(values(hand))[2] == 2)
fullhouse(hand) = (3 in values(hand) && 2 in values(hand)) || (3 in values(hand) && hand['J'] == 1 && counter(values(hand))[1] == 2) || (counter(values(hand))[2] == 2 && hand['J'] == 1)
threeofkind(hand) = 3 in values(hand) || (2 in values(hand) && hand['J'] == 1)  || (1 in values(hand) && hand['J'] == 2)
twopair(hand) = counter(values(hand))[2] == 2 || (2 in values(hand) && hand['J'] == 1) || hand['J'] == 2
onepair(hand) = 2 in values(hand) || hand['J'] > 0

hands = gethand.(input)
sorted = sortperm(hands; rev=true)

getbid(hand) = parseint(split(hand)[2])
bids = getbid.(input)

println(sum(bids[sorted] .* Vector(1:length(input))))