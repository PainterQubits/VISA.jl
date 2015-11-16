### Tektronix AWG5014C
export AWG5014C

export allWaveforms
const allWaveforms      = ASCIIString("ALL")

const minimumValue      = 0x0000
const offsetValue       = 0x1fff
const offsetPlusPPOver2 = 0x3ffe
const maximumValue      = 0x3fff

type AWG5014C <: InstrumentVISA
    vi::(VISA.ViSession)
    # wavelistArray::Array{ASCIIString,1}

    AWG5014C(x) = begin
        ins = new()
        ins.vi = x
        # wavelistArray = Array{ASCIIString,1}()
        # for (i = 1:wavelistLength(ins).state)
        #     push!(wavelistArray,wavelistName(ins,i-1))
        # end
        ins
    end

    AWG5014C() = new()
end

export AWG5014CString
type AWG5014CString <: BufferedInput
	ins::AWG5014C
	label::Label
	val::AbstractString
end

# export query, read
# query(ins::AWG5014C, msg::ASCIIString) = chomp(PyCall.pycall(ins.vi[:query],ASCIIString,msg))
# read(ins::AWG5014C) = chomp(PyCall.pycall(ins.vi[:read],ASCIIString))

export AWG5014CData
type AWG5014CData
    data::Array{Float32,1}
    marker1::Array{Bool,1}
    marker2::Array{Bool,1}
end

export AWG5014CDatum

"Amplitude should be within -1.0 and 1.0; markers 1 and 2 are just Bools."
type AWG5014CDatum
    amplitude::Float32
    marker1::Bool
    marker2::Bool

    AWG5014CDatum(amp,m1,m2) = (-1.0 <= amp <= 1.0 ? new(Float32(amp),m1,m2) : throw(OutOfRangeError()))
end

import Base.convert
# Convert from Float64 to datum. No markers unless explicitly indicated.
convert(::Type{AWG5014CDatum}, ampl::Real) = AWG5014CDatum(ampl,false,false)

# Lossy conversion back from datum.
convert{T<:Real}(::Type{T}, datum::AWG5014CDatum) = convert(T, datum.amplitude)

# Simple conversion from the nice Julia type to a packed UInt16
# Has not been checked on big endian platforms. Could have subtleties ("errors").
# Not clear how the AWG5014C is doing conversion between Integer and Real formats
# internally, which may differ from how I'm doing it.
convert(::Type{UInt16}, datum::AWG5014CDatum) = begin
    realFS = (datum.amplitude + 1.0) / 2.0
    realFS *= offsetPlusPPOver2
    intAmp = UInt16(round(realFS))
    intMarkerA = <<(convert(UInt16,datum.marker1),14)
    intMarkerB = <<(convert(UInt16,datum.marker2),15)
    return htol(intAmp | intMarker1 | intMarker2)   # htol makes sure it is little endian
end

# Simple conversion from the packed UInt16 to the nice Julia type
# Has not been checked on big endian platforms. Could have subtleties ("errors").
# Not clear how the AWG5014C is doing conversion between Integer and Real formats
# internally, which may differ from how I'm doing it.
convert(::Type{AWG5014CDatum}, int::UInt16) = begin
    hostInt = ltoh(int) # Use host endianness
    marker1 = Bool(<<(UInt16(1),14) & hostInt > 0)
    marker2 = Bool(<<(UInt16(1),15) & hostInt > 0)
    intAmp = hostInt & maximumValue
    floatAmp = Float64(intAmp) / Float64(offsetPlusPPOver2)
    floatAmp = (floatAmp * 2.0) - 1.0
    AWG5014CDatum(floatAmp, marker1, marker2)
end

# Simple array conversions
convert{T<:Real}(::Array{AWG5014CDatum,1}, array::Array{T,1}) = begin
    [convert(AWG5014CDatum, x)::AWG5014CDatum for x in array]
end

convert{T<:Real}(::Array{T,1}, array::Array{AWG5014CDatum,1}) = begin
    [convert(T, x) for x in array]
end

const noError = 0
exceptions	= Dict(
		 0	 => "No error.",
		-222 => "Out of range.",
		-224 => "Not a power of 2.",
		-330 => "Diagnostic error.",
		-340 => "Calibration error.")

InstrumentException(ins::AWG5014C, r) = InstrumentException(ins, r, exceptions[r])

responses = Dict(
	:InstrumentState 			=> Dict( 0 		=> :Stop,
								 		 2 		=> :Run,
                                         1 		=> :Wait),

	:InstrumentTiming 			=> Dict("SYNC"  => :Synchronous,
			 				            "ASYNC" => :Asynchronous),

    :InstrumentTriggerSlope     => Dict("POS" 	=> :TriggerRising,
									    "NEG" 	=> :TriggerFalling),

	:InstrumentClockSlope		=> Dict("POS"	=> :ClockRising,
										"NEG"	=> :ClockFalling),

	:InstrumentEventSlope		=> Dict("POS"	=> :EventRising,
										"NEG"	=> :EventFalling),

	:InstrumentTrigger 			=> Dict("TRIG" 	=> :Triggered,
										"CONT" 	=> :Continuous,
										"GAT"  	=> :Gated,
										"SEQ"  	=> :Sequence),

	:InstrumentClockSource		=> Dict("INT" 	=> :InternalClock,
										"EXT" 	=> :ExternalClock),

	:InstrumentOscillatorSource	=> Dict("INT" 	=> :InternalOscillator,
										"EXT" 	=> :ExternalOscillator),

	:InstrumentTriggerSource	=> Dict("INT" 	=> :InternalTrigger,
										"EXT" 	=> :ExternalTrigger),

	:InstrumentImpedance 		=> Dict(  50.0 	=> :Ohm50,
										1000.0 	=> :Ohm1k),

	:InstrumentLock 			=> Dict( 0 		=> :Local,
										 1 		=> :Remote)
)

generateResponseHandlers(AWG5014C,responses)

export AWG5014CWaveformType
abstract AWG5014CWaveformType <: InstrumentCode
abstract AWG5014CNormalization <: InstrumentCode

subtypesArray = [
    (:IntWaveform,          AWG5014CWaveformType),
    (:RealWaveform,         AWG5014CWaveformType),

    (:NotNormalized,        AWG5014CNormalization),
    (:FullScale,            AWG5014CNormalization),
    (:PreservingOffset,     AWG5014CNormalization)
]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the createCodeType function.
for ((subtypeSymb,supertype) in subtypesArray)
    PainterQB.createCodeType(subtypeSymb, supertype)
end

uniqueResponses = Dict(
    :AWG5014CWaveformType  => Dict("INT"  => :IntWaveform,
                                   "REAL" => :RealWaveform),

    :AWG5014CNormalization => Dict("NONE" => :NotNormalized,
                                   "FSC"  => :NormalizedFullScale,
                                   "ZREF" => :NormalizedPreservingOffset)
)
generateResponseHandlers(AWG5014C, uniqueResponses)

# Needed because otherwise we need to qualify the run(awg) command with the module name.
import Main.run

sfd = Dict(
    "calibrate"							=> ["*CAL?",					InstrumentException],
	"options"						    => ["*OPT?",					ASCIIString],
	"externalOscillatorDividerRate"     => ["AWGC:CLOC:DRAT", 			Int64],	# IMPLEMENT ERROR HANDLING
	"referenceClockSource"				=> ["AWGC:CLOC:SOUR", 			InstrumentClockSource],
    "numberOfAvailableChannels"         => ["AWGC:CONF:CNUM?",          Int64],
	"dcState"							=> ["AWGC:DC:STAT", 			Bool],
	"dcOutputLevel"						=> ["AWGC:DC#:VOLT:OFFS", 	    Float64],
	"repetitionRate"					=> ["AWGC:RRAT", 				Float64],
	"repetitionRateHeld"				=> ["AWGC:RRAT:HOLD",			Bool],
	"runState"							=> ["AWGC:RSTATE?",				InstrumentState],
	"runMode" 							=> ["AWGC:RMOD", 				InstrumentTrigger],
	"run"								=> ["AWGC:RUN",					InstrumentNoArgs],
	"stop"								=> ["AWGC:STOP",				InstrumentNoArgs],
    "sequencerPosition"                 => ["AWGC:SEQ:POS?",            Int64],
	"forceEvent"						=> ["EVEN",						InstrumentNoArgs],
	# The following two methods may return AWGYes() if the window *cannot* be displayed.
	# They return the correct result (AWGNo()) if the window can be displayed, but is not displayed.
	"sequenceWindowDisplayed"			=> ["DISP:WIND1:STAT", 			Bool],
	"waveformWindowDisplayed"			=> ["DISP:WIND2:STAT", 			Bool],
	"eventImpedance"					=> ["EVEN:IMP", 				InstrumentImpedance],
	"eventJumpTiming"					=> ["EVEN:JTIM", 				InstrumentTiming],
	"eventLevel"						=> ["EVEN:LEV", 				Float64],
	"eventSlope"						=> ["EVEN:POL", 				InstrumentEventSlope],
	"outputFilterFrequency"				=> ["OUTP#:FILT:FREQ", 			Float64],
	"outputState"						=> ["OUTP#:STAT", 				Bool],
	"sequencerGOTOTarget"				=> ["SEQ:ELEM#:GOTO:IND", 	    Int64],
	"sequencerGOTOState"				=> ["SEQ:ELEM#:GOTO:STAT", 	    Bool],
	"sequencerEventJumpTarget"			=> ["SEQ:ELEM#:JTAR:IND", 	    Int64],
	"sequencerLoopCount"				=> ["SEQ:ELEM#:LOOP:COUN", 	    Int64],
	"sequencerInfiniteLoop"				=> ["SEQ:ELEM#:LOOP:INF", 	    Bool],
	"sequencerLength"					=> ["SEQ:LENG", 				Int64],
	"forceSequenceJump"					=> ["SEQ:JUMP",					InstrumentNoArgs],
	"waveformLoadedInChannel"			=> ["SOUR#:FUNC:USER", 			ASCIIString],
	"markerDelay"						=> ["SOUR#:MARK#:DEL", 			Float64],
	"referenceOscillatorFrequency"	    => ["SOUR:ROSC:FREQ", 			Float64],
	"referenceOscillatorMultiplier"     => ["SOUR:ROSC:MULT", 			Int64],
	"referenceOscillatorSource" 		=> ["SOUR:ROSC:SOUR",			InstrumentOscillatorSource],
	"externalInputAddsToOutput"			=> ["SOUR#:COMB:FEED", 			ASCIIString],
	"analogOutputDelayInSeconds"		=> ["SOUR#:DELAY", 			    Float64],
	"analogOutputDelayInPoints"			=> ["SOUR#:DELAY:POIN",			Float64],
	"panelLocked" 						=> ["SYST:KLOC", 				InstrumentLock],
	"systemDate"						=> ["SYST:DATE", 				Int64],
	"systemTime"						=> ["SYST:TIME", 				Int64],
    "scpiVersion"                       => ["SYST:VERS?",               ASCIIString],
	"triggerImpedance" 					=> ["TRIG:IMP", 				InstrumentImpedance],
	"triggerLevel"						=> ["TRIG:LEV", 				Float64],
	"triggerSlope"						=> ["TRIG:POL", 				InstrumentTriggerSlope],
	"triggerTimer" 						=> ["TRIG:TIM",					Float64],
	"triggerSource"						=> ["TRIG:SOUR", 				InstrumentTriggerSource],
    "wavelistLength"                    => ["WLIST:SIZE?",              Int64],
)

for (fnName in keys(sfd))
	createStateFunction(AWG5014C,fnName,sfd[fnName][1],sfd[fnName][2])
end

# And now, the functions we decided to write by hand...

export runApplication, applicationState
export hardwareSequencerType, loadAWGSettings, saveAWGSettings, clearWaveforms
export deleteUserWaveform, waveformIsPredefined, waveformTimestamp, waveformType
export waveformName, waveformLength, pullFromAWG, pushToAWG, newWaveform

"""Run an application, e.g. SerialXpress"""
function runApplication(ins::AWG5014C, app::ASCIIString)
	write(ins,"AWGC:APPL:RUN \""+app+"\"")
end

function applicationState(ins::AWG5014C, app::ASCIIString)
	query(ins,"AWGC:APPL:STAT? \""+app+"\"") == 0 ? InstrumentStopState(ins) : InstrumentRunState(ins)
end

function hardwareSequencerType(ins::AWG5014C)
	chomp(query(ins,"AWGC:SEQ:TYPE?")) == "HARD" ? InstrumentYes(ins) : InstrumentNo(ins)
end

function loadAWGSettings(ins::AWG5014C,filePath::ASCIIString)
	write(ins,string("AWGC:SRES \"",filePath,"\""))
end

function saveAWGSettings(ins::AWG5014C,filePath::ASCIIString)
	write(ins,string("AWGC:SSAV \"",filePath,"\""))
end

function clearWaveforms(ins::AWG5014C)
    write(ins,"SOUR1:FUNC:USER \"\"")
    write(ins,"SOUR2:FUNC:USER \"\"")
    write(ins,"SOUR3:FUNC:USER \"\"")
    write(ins,"SOUR4:FUNC:USER \"\"")
end

function deleteWaveform(ins::AWG5014C, name::ASCIIString)
    write(ins, "WLIS:WAV:DEL "*quoted(name))
end

function newWaveform(ins::AWG5014C, name::ASCIIString, size::Integer, wvtype::DataType)
    @assert wvtype <: AWG5014CWaveformType "$wvtype <: AWG5014CWaveformType"
    newWaveform(ins, name, size, wvtype(ins))
end

function newWaveform(ins::AWG5014C, name::ASCIIString, numPoints::Integer, wvtype::AWG5014CWaveformType)
    write(ins, "WLIS:WAV:NEW "*quoted(name)*","*string(numPoints)*","*wvtype.state)
end

function resampleWaveform(ins::AWG5014C, name::ASCIIString, points::Integer)
    write(ins, "WLIS:WAV:RESA "*quoted(name)*","*string(points))
end

function normalizeWaveform(ins::AWG5014C, name::ASCIIString, norm::DataType)
    @assert norm <: AWG5014CNormalization "$norm <: AWG5014CNormalization"
    normalizeWaveform(ins,name,norm(ins))
end

function normalizeWaveform(ins::AWG5014C, name::ASCIIString, norm::AWG5014CNormalization)
    write(ins, "WLIS:WAV:NORM "*quoted(name)*","*norm.state)
end

function waveformName(ins::AWG5014C, num::Integer)
    strip(query(ins, "WLIST:NAME? "*string(num)),'"')
end

function waveformLength(ins::AWG5014C, name::ASCIIString)
    parse(query(ins, "WLIST:WAV:LENG? "*quoted(name)))
end

function waveformIsPredefined(ins::AWG5014C, name::ASCIIString)
    Bool(parse(query(ins,"WLIST:WAV:PRED? "*quoted(name))))
end

function waveformTimestamp(ins::AWG5014C, name::ASCIIString)
    InstrumentASCIIString(ins, query(ins,"WLIS:WAV:TST? "*quoted(name)))
end

function waveformType(ins::AWG5014C, name::ASCIIString)
    AWG5014CWaveformType(ins, query(ins,"WLIS:WAV:TYPE? "*quoted(name)))
end

function pushToAWG(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData)

    if (waveformIsPredefined(ins,name))
        error("Cannot overwrite predefined waveform")
    end

    # only real waveform implemented currently
    buf = IOBuffer()
    for (i in 1:length(awgData.data))
        Base.write(buf, htol(awgData.data[i]))
        Base.write(buf, UInt8(awgData.marker1[i]) << 6 | UInt8(awgData.marker2[i]) << 7)
    end
    binBlockWrite(ins.vi, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))

end

function pullFromAWG(ins::AWG5014C, name::ASCIIString)
    len = waveformLength(ins, name)
    typ = waveformType(ins, name)
    write(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binBlockReadAvailable(ins.vi)

    samples = Int64((io.size-io.ptr)/5)    # assuming real waveform

    amp =  Vector{Float32}(samples)
    marker1 = Vector{Bool}(samples)
    marker2 = Vector{Bool}(samples)

    for (i=1:samples)
        amp[i] = ltoh(Base.read(io,Float32))
        markers = Base.read(io,UInt8)
        marker1[i] = Bool((markers >> 6) & UInt8(1))
        marker2[i] = Bool((markers >> 7) & UInt8(1))
    end

    AWG5014CData(amp,marker1,marker2)
end

# function _pullFromAWG(ins::AWG5014C, name::ASCIIString, ::RealWaveform, ::Type{Val{false}})
#     len = waveformLength(ins, name)
#     array = ins.vi[:query_binary_values]("WLIST:WAV:DATA? "*quoted(name),datatype=("Bf"^len)*"B",is_big_endian=false)
#     [Float32(array[2*x-1])::Float32 for x in 1:len]
# end

# Probably could be written faster. Assumes 2 bytes per sample, okay for AWG5014C
function _pullFromAWG(ins::AWG5014C, name::ASCIIString, ::IntWaveform)
    # NOT YET implemented

    # startNum = string[2] + 3
    # uint8array = takebuf_array(IOBuffer(string[startNum:end]))
    # numValues = (length(uint8array) / bytesPerAWGDatum)::Int64
    # uint16array = [UInt16(uint8array[2*x-1]) << 8 | UInt16(uint8array[2*x]) for x in numValues]
    # [convert(AWG5014CDatum, x) for x in uint16array]
end
