using VISA
resourceManager = viOpenDefaultRM()

export resourceManager

export Instrument, InstrumentVISA

export InstrumentCode, InstrumentNoArgs

export InstrumentNetwork, InstrumentState, InstrumentTiming
export InstrumentTriggerSlope, InstrumentEventSlope, InstrumentClockSlope
export InstrumentError, InstrumentClockSource, InstrumentTriggerSource
export InstrumentOscillatorSource, InstrumentTrigger, InstrumentPolarity
export InstrumentImpedance, InstrumentLock, InstrumentSearch, InstrumentSParameter
export InstrumentMedium, InstrumentSampleRate, InstrumentDataFormat, InstrumentCoupling

export InstrumentException

export gpib, tcpip
export query, read, write, readavailable
export test, reset, identify, clearRegisters, trigger, abortTrigger
export quoted

"""
### Instrument
`abstract Instrument <: Any`

Abstract supertype of all concrete Instrument types, e.g. `AWG5014C <: Instrument`.
"""
abstract Instrument
abstract InstrumentVISA <: Instrument

"""
### InstrumentCode
`abstract InstrumentCode <: Any`

Abstract supertype of all abstract types representing communications with an instrument.

Each *abstract* subtype one level down should represent a logical state of the instrument configuration,
e.g. `InstrumentReference` may be have concrete subtypes `InstrumentExternal` or `InstrumentInternal`.

Each *concrete* subtype two levels down is immutable and should have two fields:
`ins::Instrument`
`state::T`
where the type `T` can be parametric. The `state` value should encode how the instrument in question
encodes the logical state in communication. For example, InstrumentExternal with an AWG5014C instrument
might have "EXT" for the state field.
"""
abstract InstrumentCode

abstract InstrumentNoArgs <: InstrumentCode

abstract InstrumentNetwork <: InstrumentCode
abstract InstrumentState <: InstrumentCode
abstract InstrumentTiming <: InstrumentCode
abstract InstrumentClockSlope <: InstrumentCode
abstract InstrumentTriggerSlope <: InstrumentCode
abstract InstrumentEventSlope <: InstrumentCode
abstract InstrumentClockSource <: InstrumentCode
abstract InstrumentTriggerSource <: InstrumentCode
abstract InstrumentOscillatorSource <: InstrumentCode
abstract InstrumentTrigger <: InstrumentCode
abstract InstrumentPolarity <: InstrumentCode
abstract InstrumentImpedance <: InstrumentCode
abstract InstrumentLock <: InstrumentCode
abstract InstrumentSearch <: InstrumentCode
abstract InstrumentSParameter <: InstrumentCode
abstract InstrumentMedium <: InstrumentCode
abstract InstrumentSampleRate <: InstrumentCode
abstract InstrumentDataRepresentation <: InstrumentCode
abstract InstrumentDataPacking <: InstrumentCode
abstract InstrumentCoupling <: InstrumentCode

immutable InstrumentException <: Exception
		ins::Instrument
		val::Int64
		humanReadable::UTF8String
end
Base.showerror(io::IO, e::InstrumentException) = print(io, "$(e.ins): $(e.humanReadable) (error code $(e.val))")

# The subtypesArray is used to generate concrete types of the abstract subtypes
# of InstrumentCode (see just above for some examples). The keys are strings containing
# the names of the concrete types, and the values are the respective abstract types.
subtypesArray = [
    (:AC							, InstrumentCoupling),
	(:DC							, InstrumentCoupling),

	(:DHCP 							, InstrumentNetwork),
	(:ManualNetwork 				, InstrumentNetwork),

	(:Stop							, InstrumentState),
	(:Run							, InstrumentState),
	(:Wait							, InstrumentState),

	(:Asynchronous					, InstrumentTiming),	#AWG5014C
	(:Synchronous					, InstrumentTiming),
	(:Before						, InstrumentTiming),	#E5071C
	(:After							, InstrumentTiming),

	(:ClockRising					, InstrumentClockSlope),
	(:ClockFalling					, InstrumentClockSlope),

	(:RisingTrigger					, InstrumentTriggerSlope),
	(:FallingTrigger				, InstrumentTriggerSlope),

	(:RisingEvent					, InstrumentEventSlope),
	(:FallingEvent					, InstrumentEventSlope),

	(:PositivePolarity				, InstrumentPolarity),
	(:NegativePolarity				, InstrumentPolarity),

	(:InternalClock					, InstrumentClockSource),
	(:ExternalClock					, InstrumentClockSource),

	(:InternalTrigger				, InstrumentTriggerSource),
	(:ExternalTrigger				, InstrumentTriggerSource),
	(:ManualTrigger					, InstrumentTriggerSource),
	(:BusTrigger					, InstrumentTriggerSource),

	(:InternalOscillator			, InstrumentOscillatorSource),
	(:ExternalOscillator			, InstrumentOscillatorSource),

	(:Triggered						, InstrumentTrigger),
	(:Continuous				    , InstrumentTrigger),
	(:Gated							, InstrumentTrigger),
	(:Sequence						, InstrumentTrigger),

	(:Ohm50						    , InstrumentImpedance),
	(:Ohm1k							, InstrumentImpedance),

	(:Local							, InstrumentLock),
	(:Remote						, InstrumentLock),

	(:Max							, InstrumentSearch),
	(:Min							, InstrumentSearch),
	(:Peak							, InstrumentSearch),
	(:LeftPeak						, InstrumentSearch),
	(:RightPeak						, InstrumentSearch),
	(:Target						, InstrumentSearch),
	(:LeftTarget					, InstrumentSearch),
	(:RightTarget					, InstrumentSearch),

	(:S11							, InstrumentSParameter),
	(:S12							, InstrumentSParameter),
	(:S21							, InstrumentSParameter),
	(:S22						    , InstrumentSParameter),

	(:Coaxial						, InstrumentMedium),
	(:Waveguide						, InstrumentMedium),

	(:Rate1kSps						, InstrumentSampleRate),
 	(:Rate2kSps						, InstrumentSampleRate),
 	(:Rate5kSps						, InstrumentSampleRate),
 	(:Rate10kSps					, InstrumentSampleRate),
 	(:Rate20kSps					, InstrumentSampleRate),
 	(:Rate50kSps					, InstrumentSampleRate),
 	(:Rate100kSps					, InstrumentSampleRate),
 	(:Rate200kSps					, InstrumentSampleRate),
 	(:Rate500kSps					, InstrumentSampleRate),
 	(:Rate1MSps						, InstrumentSampleRate),
 	(:Rate2MSps						, InstrumentSampleRate),
 	(:Rate5MSps						, InstrumentSampleRate),
 	(:Rate10MSps					, InstrumentSampleRate),
 	(:Rate20MSps					, InstrumentSampleRate),
 	(:Rate50MSps					, InstrumentSampleRate),
 	(:Rate100MSps					, InstrumentSampleRate),
 	(:Rate200MSps					, InstrumentSampleRate),
 	(:Rate500MSps					, InstrumentSampleRate),
 	(:Rate800MSps					, InstrumentSampleRate),
 	(:Rate1000MSps					, InstrumentSampleRate),
 	(:Rate1200MSps					, InstrumentSampleRate),
 	(:Rate1500MSps					, InstrumentSampleRate),
 	(:Rate1800MSps					, InstrumentSampleRate),
	(:RateUser						, InstrumentSampleRate),

	(:LogMagnitude					, InstrumentDataRepresentation),
	(:Phase							, InstrumentDataRepresentation),
	(:GroupDelay					, InstrumentDataRepresentation),
	(:SmithLinear					, InstrumentDataRepresentation),
	(:SmithLog						, InstrumentDataRepresentation),
	(:SmithComplex					, InstrumentDataRepresentation),
	(:Smith							, InstrumentDataRepresentation),
	(:SmithAdmittance				, InstrumentDataRepresentation),
	(:PolarLinear					, InstrumentDataRepresentation),
	(:PolarLog						, InstrumentDataRepresentation),
	(:PolarComplex					, InstrumentDataRepresentation),
	(:LinearMagnitude				, InstrumentDataRepresentation),
	(:SWR							, InstrumentDataRepresentation),
	(:RealPart						, InstrumentDataRepresentation),
	(:ImaginaryPart					, InstrumentDataRepresentation),
	(:ExpandedPhase					, InstrumentDataRepresentation),
	(:PositivePhase					, InstrumentDataRepresentation),

    (:DefaultPacking                , InstrumentDataPacking),
    (:Pack8Bits                     , InstrumentDataPacking),
    (:Pack12Bits                    , InstrumentDataPacking)

]::Array{Tuple{Symbol,DataType},1}

function createCodeType(subtype::Symbol, supertype::DataType)
	@eval immutable ($subtype){T} <: $supertype
			ins::Instrument
			state::T
	#		Test3(a,b)=new(a,b)
	#    Test3()=new()
		end
		# Test3{T}(a::PainterQB.Instrument,b::T) = Test3{T}(a,b)
		# Test3() = Test3{Void}()
	@eval export $subtype
end

# Create all the concrete types we need using the createCodeType function.
for ((subtypeSymb,supertype) in subtypesArray)
	createCodeType(subtypeSymb, supertype)
end

# Note that it is tempting to do this as a macro, but you are not allowed to
# export from a local scope, so there are some headaches with for loops, etc.

typealias Rate1GSps Rate1000MSps

"""
### createStateFunction

`createStateFunction{S<:Instrument,T<:Union{InstrumentCode,Number,AbstractString}}
    (instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})`

For each `command`, there may be up to two functions generated, provided `command` contains no # signs. For example, if:

```
instrumentType == AWG5014C
fnName == "triggerSource"
command == "TRIG:REF"
setArgType == InstrumentTriggerSource
```

then we would have the functions:

```
function triggerSource(ins::AWG5014C)
	result = query(ins, "TRIG:REF?")
	InstrumentTriggerSource(ins,result)
end

function setTriggerSource(ins::AWG5014C, x::InstrumentTriggerSource)
	write(ins, string("TRIG:REF ",x.state))
end
```

If there were a `?` at the end of `command` then only the first function would be generated.
If `setArgType` is `InstrumentNoArgs` then the second function is generated with fnName, e.g. if:

```
instrumentType == AWG5014C
fnName == "run"
command == "AWGC:RUN"
setArgType == InstrumentNoArgs
```

then

```
function run(ins::AWG5014C)
    write(ins, "AWGC:RUN")
end
```

would be generated.

If we have # signs in `command`, then each function becomes a *varargs* function,
with a variable number of Int64 arguments at the end. These are used to allow for
infixing of `command` whereever a # sign is. Some commands sent to instruments need
this, especially if there are multiple channels that each respond to a command.

There are some other details buried in here, for instance we have some methods
that allow for conveniently passing numbers or strings rather than explicitly generating
InstrumentNumber or InstrumentString objects.

"""
function createStateFunction{S<:Instrument,T<:Union{InstrumentCode,Number,AbstractString}}(instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    createGettingFunction(instrumentType,fnName,command,setArgType)

	# Create setting function?
	if (command[end]=='?')
		return
	end

    createSettingFunction(instrumentType,fnName,command,setArgType)

end

function createStateFunction{S<:Instrument}(instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{InstrumentNoArgs})
	nameSymb = symbol(fnName)

	@eval function ($nameSymb)(ins::$instrumentType, infixes::Int64...)
		cmd = $command
		for (infix in infixes)
			cmd = replace(cmd,"#",infix,1)
		end
		write(ins, string(cmd))
	end

	@eval export $nameSymb
end

function createStateFunction{S<:Instrument}(instrumentType::Type{S},fnName::ASCIIString, command::ASCIIString, setArgType::Type{InstrumentException})
    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = query(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)(ins,response)
    end
    @eval export $readNameSymb
end

function createGettingFunction{S<:Instrument, T<:InstrumentCode}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

	readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = query(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)(ins,response)
    end
    @eval export $readNameSymb
end

function createGettingFunction{S<:Instrument, T<:Union{Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = query(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)($setArgType <: Number ? parse(response) : response)
    end
    @eval export $readNameSymb
end

function createSettingFunction{S<:Instrument, T<:InstrumentCode}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

	setNameSymb = symbol(string("set",ucfirst(fnName)))

    # Take object as argument
	@eval function ($setNameSymb)(ins::$instrumentType, x::$setArgType, infixes::Int64...)
		cmd = $command
		for (infix in infixes)
			cmd = replace(cmd,"#",infix,1)
		end
	write(ins, string(cmd," ",x.state))
	end

	# Take type as argument
	@eval function ($setNameSymb){}(ins::$instrumentType, x::Type{$setArgType}, infixes::Int64...)
		@assert x <: $setArgType "$x <: "*string($setArgType)
		cmd = $command
		for (infix in infixes)
			cmd = replace(cmd,"#",infix,1)
		end
	#	@assert ($x in responseDict.values.values)
		write(ins, string(cmd," ",(x)(ins).state))
	end

	@eval export $setNameSymb

end

function createSettingFunction{S<:Instrument, T<:Union{Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    setNameSymb = symbol(string("set",ucfirst(fnName)))

    @eval function ($setNameSymb)(ins::$instrumentType, x::$setArgType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        write(ins, string(cmd," ",($setArgType === Bool ? Int64(x) : x)))
    end

    @eval export $setNameSymb
end

"""
### generateResponseHandlers

`generateResponseHandlers(insType::DataType, responseDict::Dict)`

Each instrument can have a `responseDictionary`. For each setting of the instrument,
for instance the `InstrumentClockSource`, we need to know the correspondence between a
logical state `ExternalClock` and how the instrument encodes that logical state, "EXT".
The responseDictionary is actually a dictionary of dictionaries. The first level keys
are like `InstrumentClockSource` and the second level keys are like "EXT".

This function makes a lot of other functions. Given some response from an instrument,
we require a function to map that response back on to the appropiate logical state.

`InstrumentClockSource(ins::AWG5014C,response::Any)`
returns an `InternalClock(ins,response)` or `ExternalClock(ins,response)` object as appropriate,
based on the logical meaning of the response.

We also want a function to generate logical states without having to know the way
they are encoded by the instrument.

`InternalClock(ins::Instrument)`
returns an `InternalClock(ins,"INT")` object, with "INT" encoding how to pass this logical state
to the instrument `ins`.
"""
function generateResponseHandlers(insType::DataType, responseDict::Dict)

	for (supertypeSymb in keys(responseDict))
		# Generate outer constructors for concrete InstrumentCodes (e.g. InstrumentInternal) specific to this insType.
		d = responseDict[supertypeSymb]
		for (response in keys(d))
			fnSymb = d[response]
			@eval ($fnSymb)(ins::$insType) = ($fnSymb)(ins,$response)
		#	@eval ($fnSymb)() = ($fnSymb)()
		end

		# Generate response handlers for abstract InstrumentCodes (e.g. InstrumentReference) to make the correct concrete type (e.g. InstrumentInternal)
		@eval ($supertypeSymb)(ins::$insType,res::AbstractString) =
			(typeof(parse(res)) <: Number ?
			Expr(:call, ($d)[parse(res)],  ins)  :
			Expr(:call, ($d)[res],	  		 ins)) |> eval

        @eval ($supertypeSymb)(ins::$insType,res::Number) = Expr(:call, ($d)[res], ins) |> eval
	end

end

gpib(primary) = viOpen(resourceManager, "GPIB::"*primary*"::0::INSTR")
gpib(board, primary) = viOpen(resourceManager, "GPIB"*(board == 0 ? "" : board)+"::"*primary*"::0::INSTR")
gpib(board, primary, secondary) = viOpen(resourceManager, "GPIB"*(board == 0 ? "" : board)*"::"+primary+"::"+secondary+"::INSTR")
tcpip(ip) = viOpen(resourceManager, "TCPIP::"*ip*"::INSTR")

function query(ins::InstrumentVISA, msg::ASCIIString, delay::Real=0)
	write(ins, msg)
	sleep(delay)
	read(ins)
end
read(ins::InstrumentVISA) = rstrip(bytestring(viRead(ins.vi)), ['\r', '\n'])
write(ins::InstrumentVISA, msg::ASCIIString) = viWrite(ins.vi, msg)
readavailable(ins::InstrumentVISA) = VISA.readavailable(ins.vi)

find_resources(expr::AbstractString="?*::INSTR") = viFindRsrc(resourceManager, expr)

# Define commands implemented by several instruments.
test(ins::InstrumentVISA) 			= write(ins, "*TST?")
reset(ins::InstrumentVISA) 			= write(ins, "*RST")
identify(ins::InstrumentVISA) 	    = query(ins, "*IDN?")
clearRegisters(ins::InstrumentVISA) = write(ins, "*CLS")
trigger(ins::InstrumentVISA) 		= write(ins, "*TRG")
abortTrigger(ins::InstrumentVISA)	= write(ins, "ABOR")

quoted(str::ASCIIString) = "\""*str*"\""
