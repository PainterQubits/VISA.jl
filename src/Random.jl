export RandomInput
type RandomInput <: Input
end

export measure
measure(ch::RandomInput) = rand()
