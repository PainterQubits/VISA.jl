### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns 

export TimeOutput, TimeInput

type TimeOutput <: Output
	t0::Float64
end

type TimeInput <: Input
	t0::Float64
end

TimeInput() = TimeInput(time())
TimeOutput() = TimeOutput(time())

function source(ch::TimeOutput, val::Real)
	if val < eps()
		ch.t0 = time()
	else
		while val + ch.t0 > time()
			sleep(0.01)
		end
	end
end

measure(ch::TimeInput) = time() - ch.t0