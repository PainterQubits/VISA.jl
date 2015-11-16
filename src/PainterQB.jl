@windows? include("visa\\VISA.jl") : include("visa/VISA.jl")

module PainterQB
#
# export Channel, Input, Output, BufferedInput, BufferedOutput, VirtualOutput
# export PID, Calculated, Label

### Channel abstract type and subtypes
# required attributes:
# 	current value, label and unit?
# required functions:

abstract Channel

abstract Input <: Channel
abstract Output <: Channel
abstract BufferedInput <: Input
abstract BufferedOutput <: Output
abstract VirtualOutput <: Output
abstract PID <: Channel
abstract Calculated <: Input

type Label
	name::AbstractString
	unit::AbstractString
end

# Instruments and channels
include("Instrument.jl")
#include("E5071C.jl")
#include("E8257D.jl")
@windows? include("hardware\\AWG5014C.jl") : include("hardware/AWG5014C.jl")

# Utility channels

include("Random.jl")
include("Time.jl")

# Utility functions

# include("Sweep.jl")
# include("Trace3.jl")

end
