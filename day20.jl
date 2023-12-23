using DataStructures

include("utils.jl")

input = readinput()

abstract type Pulse end

struct High <: Pulse end
struct Low <: Pulse end

abstract type PModule end

mutable struct FlipFlop <: PModule
    on::Bool
    destinations::Vector{PModule}
end
FlipFlop(destinations::Vector{PModule}) = FlipFlop(false, destinations)
FlipFlop() = FlipFlop(PModule[])
Base.show(io::IO, z::FlipFlop) = print(io, "FlipFlop module with $(length(z.destinations)) destinations: $(z.on ? "On" : "Off")")


mutable struct Conjunction <: PModule
    memory::Dict{PModule, Pulse}
    destinations::Vector{PModule}
end
Conjunction(destinations::Vector{PModule}) = Conjunction(Dict(), destinations)
Conjunction() = Conjunction(PModule[])
Base.show(io::IO, z::Conjunction) = print(io, "Conjunction module with $(length(z.destinations)) destinations")

struct Broadcast <: PModule
    destinations::Vector{PModule}
end
Broadcast() = Broadcast(PModule[])
Base.show(io::IO, z::Broadcast) = print(io, "Broadcast module with $(length(z.destinations)) destinations")

struct Placeholder <: PModule end

function PModule(line)
    name, targets = split(line, " -> ")
    splittargets = split(targets, ", ")
    name == "broadcaster" && return(Broadcast(), "broadcaster", splittargets)
    name[1]=='%' && return(FlipFlop(), name[2:end], splittargets)
    name[1]=='&' && return(Conjunction(), name[2:end], splittargets)
end

function getmodules(input)
    modules = Dict{AbstractString, PModule}()
    moduletargets = Dict{AbstractString, Vector{AbstractString}}()
    for line in input
        mod, name, targets = PModule(line)
        modules[name] = mod
        moduletargets[name] = targets
    end
    for key in keys(moduletargets)
        for k in moduletargets[key]
            !(k in keys(modules)) && (modules[k] = Placeholder())
            target = modules[k]
            push!(modules[key].destinations, target)
            target isa Conjunction && (target.memory[modules[key]] = Low())
        end
    end
    modules
end

mutable struct LHCounter
    low::Int
    high::Int
end
LHCounter() = LHCounter(0, 0)
inc(counter::LHCounter, pulse::Low) = counter.low += 1
inc(counter::LHCounter, pulse::High) = counter.high += 1

dopulse(mod::Placeholder, pulse::Pulse, from::PModule) = []
dopulse(mod::Broadcast, pulse::Pulse, from::PModule) = [(x, Low(), mod) for x in mod.destinations]
dopulse(mod::FlipFlop, pulse::High, from::PModule) = []
function dopulse(mod::FlipFlop, pulse::Low, from::PModule)
    mod.on = !mod.on
    pulse = mod.on ? High() : Low()
    [(x, pulse, mod) for x in mod.destinations]
end
highs(mod::Conjunction) = all([x == High() for x in values(mod.memory)])
function dopulse(mod::Conjunction, pulse::Pulse, from::PModule)
    mod.memory[from] = pulse
    pulse = highs(mod) ? Low() : High()
    [(x, pulse, mod) for x in mod.destinations]
end


pushbutton(modules::Dict{AbstractString, PModule}) = pushbutton(modules, LHCounter())
function pushbutton(modules::Dict{AbstractString, PModule}, counter::LHCounter)
    pulses = Queue{Tuple{PModule, Pulse, PModule}}()
    enqueue!(pulses, (modules["broadcaster"], Low(), modules["broadcaster"]))
    while !isempty(pulses)
        mod, pulse, from = dequeue!(pulses)
        inc(counter, pulse)
        newpulses = dopulse(mod, pulse, from)
        for pulsecombo in newpulses
            enqueue!(pulses, pulsecombo)
        end
    end
    return counter
end

function main(input; presses=1000)
    modules = getmodules(input)
    counter = LHCounter()
    for _ in 1:presses
        pushbutton(modules, counter)
    end
    return counter.low * counter.high
end

println(main(input))

function pushbuttonrx(modules::Dict{AbstractString, PModule})
    rx = modules["rx"]
    pulses = Queue{Tuple{PModule, Pulse, PModule}}()
    enqueue!(pulses, (modules["broadcaster"], Low(), modules["broadcaster"]))
    while !isempty(pulses)
        mod, pulse, from = dequeue!(pulses)
        mod == rx && pulse == Low() && return(true)
        newpulses = dopulse(mod, pulse, from)
        for pulsecombo in newpulses
            enqueue!(pulses, pulsecombo)
        end
    end
    return false
end

function mainp2(input)
    modules = getmodules(input)
    found = false
    presses = 0
    while !found
        presses += 1
        found |= pushbuttonrx(modules)
    end
    return presses
end

println(mainp2(input))