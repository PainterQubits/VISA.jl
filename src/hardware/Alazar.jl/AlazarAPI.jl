"""
Julia interface to the AlazarTech SDK.
Adapted from the C and Python APIs by Andrew Keller (andrew.keller.09@gmail.com)

This module provides a thin wrapper on top of the AlazarTech C
API. All the exported methods directly map to underlying C
functions. Please see the ATS-SDK Guide for detailed specification of
these functions. In addition, this module provides a few classes for
convenience.

Types

InstrumentAlazar: Represents a digitizer. Abstract type.
AlazarATS9360: Concrete type.

DMABuffer: Holds a memory buffer suitable for data transfer with digitizers.
"""

module Alazar

using PainterQB

# Machine specific
const maxThroughputGBs = 175e7 #18e8

export U32, U8
typealias U32 Culong
typealias U8 Cuchar

U32(x) = convert(U32,x)
U8(x) = convert(U8,x)

# Define constants and exceptions
include("AlazarConstants.jl")

# Play nice with Instruments
export AlazarAux, AlazarDataPacking, AlazarChannel
abstract AlazarAux <: InstrumentCode
abstract AlazarDataPacking <: InstrumentCode
abstract AlazarChannel <: InstrumentCode

subtypesArray = [
    (:ChannelA                          , AlazarChannel),
    (:ChannelB                          , AlazarChannel),
    (:BothChannels                      , AlazarChannel),

    (:AuxOutputTrigger					, AlazarAux),
    (:AuxInputTriggerEnable		        , AlazarAux),
    (:AuxOutputPacer				    , AlazarAux),
    (:AuxDigitalInput					, AlazarAux),
    (:AuxDigitalOutput				    , AlazarAux)#,

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the createCodeType function.
for ((subtypeSymb,supertype) in subtypesArray)
    PainterQB.createCodeType(subtypeSymb, supertype)
end

# Load libraries
# DL_LOAD_PATH = @windows? "C:\\Users\\Discord\\Documents\\" : "/usr/local/lib/"
const ats = @windows? "ATSApi.dll" : "libATSApi.so"
const libc = "libc.so.6"

@windows? begin
    atsHandle = Libdl.dlopen(ats)
    atexit(()->Libdl.dlclose(atsHandle))
end : (@linux? begin
    atsHandle = Libdl.dlopen(ats)
    libcHandle = Libdl.dlopen(libc)
    atexit(()->begin
        Libdl.dlclose(atsHandle)
        Libdl.dlclose(libcHandle)
    end)
end : throw(SystemError("OS not supported")))

export DMABuffer
"""
Buffer suitable for DMA transfers.

AlazarTech digitizers use direct memory access (DMA) to transfer
data from digitizers to the computer's main memory. This class
abstracts a memory buffer on the host, and ensures that all the
requirements for DMA transfers are met.

DMABuffers export a 'buffer' member, which is a Julia Array
of the underlying memory buffer

Args:

  bytesPerSample (int): The number of bytes per samples of the
  data. This varies with digitizer models and configurations.

  sizeBytes (int): The size of the buffer to allocate, in bytes.

*Something to watch out for: this code does not support 32-bit systems!*
... but who would measure qubits with that anyway?
"""
type DMABuffer{cSampleType <: Union{UInt16,UInt8}}
    bytesPerSample::Culonglong
    sizeBytes::Culonglong
    addr::Ptr{cSampleType}
    array::Array{cSampleType}

    DMABuffer(bytesPerSample, sizeBytes) = begin
    if (typeof(bytesPerSample) != Culonglong || typeof(sizeBytes) != Culonglong)
        throw(ArgumentError("You should be more careful using inner constructors..."))
    end

    # Only Windows or UNIX supported, not OS X...?
    @windows? begin
        MEM_COMMIT = U32(0x1000)
        PAGE_READWRITE = U32(0x4)
        addr = ccall((:VirtualAlloc,"Kernel32"), Ptr{cSampleType}, (Ptr{Void},Culonglong,Culong,Culong), C_NULL, sizeBytes, MEM_COMMIT, PAGE_READWRITE)
    end : (@linux? begin
        addr = ccall((:valloc,libc), Ptr{cSampleType}, (Culonglong,), sizeBytes)    #Culong, ?
    end : throw(SystemError()))

    if (addr == C_NULL)
        throw(OutOfMemoryError())
    end

    buffer = pointer_to_array(addr, fld(sizeBytes, bytesPerSample), false)
    dmabuf = new(bytesPerSample, sizeBytes, addr, buffer)

    finalizer(dmabuf, destroy)
    return dmabuf
    end
end

DMABuffer(bytesPerSample::Culonglong, sizeBytes::Culonglong) = (bytesPerSample > 1) ?
    DMABuffer{UInt16}(bytesPerSample, sizeBytes) : DMABuffer{UInt8}(bytesPerSample, sizeBytes)
DMABuffer(a, b) = DMABuffer(convert(Culonglong,a),convert(Culonglong,b))

# Not to be called by the user!
destroy(buf::DMABuffer) = begin
    @windows? begin
        MEM_RELEASE = 0x8000
        ccall((:VirtualFree,"Kernel32"),Cint,(Ptr{Void},Culonglong,Culong),buf.addr,Culonglong(0),MEM_RELEASE)
    end : (@linux? begin
        ccall((:free,"libc"),Void,(Ptr{Void},),buf.addr)
    end : throw(SystemError()))
end

"""
The InstrumentAlazar types represent an AlazarTech device on the local
system. It can be used to control configuration parameters, to
start acquisitions and to retrieve the acquired data.

Args:

  systemId (int): The board system identifier of the target
  board. Defaults to 1, which is suitable when there is only one
  board in the system.

  boardId (int): The target's board identifier in it's
  system. Defaults to 1, which is suitable when there is only one
  board in the system.

"""
abstract InstrumentAlazar <: Instrument
export InstrumentAlazar
include("AlazarErrors.jl")

export abortAsyncRead, abortCapture, beforeAsyncRead, boardsInSystemBySystemID
export busy, configureAuxIO, configureLSB, configureRecordAverage, forceTrigger
export forceTriggerEnable, getChannelInfo, getChannelInfo_unsafe, inputControl
export numOfSystems, postAsyncBuffer, read, readEx, resetTimeStamp, setBWLimit
export setCaptureClock, setExternalClockLevel, setExternalTrigger, setLED
export setParameter, setParameterUL, setRecordCount, setRecordSize, setTriggerDelaySamples
export setTriggerOperation, setTriggerTimeout, setTriggerTimeoutTicks, sleepDevice, startCapture
export triggered, waitAsyncBufferComplete

@eh abortAsyncRead(a::InstrumentAlazar) = ccall((:AlazarAbortAsyncRead,ats),U32,(U32,),a.handle)
@doc "Cancels any asynchronous acquisition running on a board." abortAsyncRead

@eh abortCapture(a::InstrumentAlazar) = ccall((:AlazarAbortCapture,ats),U32,(U32,),a.handle)
@doc "Abort an acquisition to on-board memory." abortCapture

@eh beforeAsyncRead(a::InstrumentAlazar, channels, transferOffset, samplesPerRecord,
    recordsPerBuffer, recordsPerAcquisition, flags) = ccall((:AlazarBeforeAsyncRead,ats),U32,(U32, U32, Clong, U32, U32, U32, U32),
    a.handle, channels, transferOffset, samplesPerRecord, recordsPerBuffer, recordsPerAcquisition, flags)
@doc "Prepares the board for an asynchronous acquisition." beforeAsyncRead

@eh boardsInSystemBySystemID(sid::Integer) = ccall((:AlazarBoardsInSystemBySystemID,ats),Culong,(Culong,),sid)
@doc "Queries the number of boards in the system?" boardsInSystemBySystemID

busy(a::InstrumentAlazar) = (ccall((:AlazarBusy,ats),U32,(U32,),a.handle) > 0) ? true : false
@doc "Determine if an acquisition to on-board memory is in progress." busy

@eh configureAuxIO(a::InstrumentAlazar, mode, parameter) =
    ccall((:AlazarConfigureAuxIO,ats), U32, (U32,U32,U32), a.handle, mode, parameter)
@doc "Configures the auxiliary output." configureAuxIO

@eh configureLSB(a::InstrumentAlazar, valueLSB0, valueLSB1) =
    ccall((:AlazarConfigureLSB,ats),U32,(U32,U32,U32), a.handle, valueLSB0, valueLSB1)
@doc "Change unused bits to digital outputs." configureLSB

@eh configureRecordAverage(a::InstrumentAlazar, mode, samplesPerRecord, recordsPerAverage, options) =
    ccall((:AlazarConfigureRecordAverage,ats),U32,(U32,U32,U32,U32,U32),
    a.handle, mode, samplesPerRecord, recordsPerAverage, options)
@doc "Co-add ADC samples into accumulator record." configureRecordAverage

@eh forceTrigger(a::InstrumentAlazar) = ccall((:AlazarForceTrigger,ats),U32,(U32,),a.handle)
@doc "Generate a software trigger event." forceTrigger

@eh forceTriggerEnable(a::InstrumentAlazar) = ccall((:AlazarForceTriggerEnable,ats),U32,(U32,),a.handle)
@doc "Generate a software trigger enable event." forceTriggerEnable

"Get the on-board memory in samples per channel and sample size in bits per sample."
getChannelInfo(a::InstrumentAlazar) = begin
    memorySize_samples = Array{U32}(1)
    memorySize_samples[1] = U32(0)
    bitsPerSample = Array{U8}(1)
    bitsPerSample[1] = U8(0)
    r = ccall((:AlazarGetChannelInfo,ats), U32, (U32,Ptr{U32},Ptr{U8}), a.handle, memorySize_samples, bitsPerSample)
    if (r != noError)
        throw(InstrumentException(a,r))
    end
    return (memorySize_samples[1], bitsPerSample[1])
end

@eh inputControl(a::InstrumentAlazar, channel, coupling, inputRange, impedance) =
    ccall((:AlazarInputControl,ats),U32,(U32, U8, U32, U32, U32), a.handle, channel, coupling, inputRange, impedance)
@doc "Configures one input channel on a board." inputControl

numOfSystems() = ccall((:AlazarNumOfSystems,ats),U32,())
@doc "Returns the number of board systems installed." numOfSystems

@eh postAsyncBuffer(a::InstrumentAlazar, buffer, bufferLength) =
    ccall((:AlazarPostAsyncBuffer,ats),U32,(U32,Ptr{Void},U32),a.handle, buffer, bufferLength)
@doc "Posts a DMA buffer to a board." postAsyncBuffer

@eh read(a::InstrumentAlazar, channelId, buffer, elementSize, record, transferOffset, transferLength) =
    ccall((:AlazarRead,ats), U32, (U32, U32, Ptr{Void}, Cint, Clong, Clong, U32),
      a.handle, channelId, buffer, elementSize, record, transferOffset, transferLength)
@doc "Read all or part of a record from on-board memory." read

@eh readEx(a::InstrumentAlazar, channelId, buffer, elementSize, record, transferOffset, transferLength) =
    ccall((:AlazarReadEx,ats), U32, (U32, U32, Ptr{Void}, Cint, Clong, Clonglong, U32),
    a.handle, channelId, buffer, elementSize, record, transferOffset, transferLength)
@doc "Read all or part of a record from on-board memory." readEx

@eh resetTimeStamp(a::InstrumentAlazar, option) =
    ccall((:AlazarResetTimeStamp,ats),U32,(U32,U32),a.handle, option)
@doc "Control record timestamp counter reset." resetTimeStamp

@eh setBWLimit(a::InstrumentAlazar, channel, enable) =
    ccall((:AlazarSetBWLimit,ats), U32, (U32, U32, U32), a.handle, channel, enable)
@doc "Activates or deactivates the low-pass filter on a given channel." setBWLimit

@eh setCaptureClock(a::InstrumentAlazar, source, rate, edge, decimation) =
    ccall((:AlazarSetCaptureClock,ats), U32, (U32, U32, U32, U32, U32), a.handle, source, rate, edge, decimation) #int(source), int(rate), int(edge)
@doc "Configures the board's acquisition clock." setCaptureClock

@eh setExternalClockLevel(a::InstrumentAlazar, level_percent) =
    ccall((:AlazarSetExternalClockLevel,ats), U32, (U32, Cfloat), a.handle, level_percent)
@doc "Set the external clock comparator level." setExternalClockLevel

@eh setExternalTrigger(a::InstrumentAlazar, coupling, range) =
    ccall((:AlazarSetExternalTrigger,ats), U32, (U32,U32,U32), a.handle, coupling, range)
@doc "Configure the external trigger." setExternalTrigger

@eh setLED(a::InstrumentAlazar, ledState) = ccall((:AlazarSetLED,ats),U32,(U32,U32), a.handle, ledState)
@doc "Control LED on a board's mounting bracket." setLED

@eh setParameter(a::InstrumentAlazar, channelId, parameterId, value) =
    ccall((:AlazarSetParameter,ats),U32,(U32,U8,U32,Ptr{Clong}), a.handle, channelId, parameterId, value)
@doc "Set a device parameter as a signed long value." setParameter

@eh setParameterUL(a::InstrumentAlazar, channelId, parameterId, value) =
    ccall((:AlazarSetParameterUL,ats),U32,(U32,U8,U32,Ptr{U32}), a.handle, channelId, parameterId, value)
@doc "Set a device parameter as a U32 value." setParameterUL

@eh setRecordCount(a::InstrumentAlazar, count) = ccode((:AlazarSetRecordCount,ats),U32,(U32,U32), a.handle, count)
@doc "Configure the record count for single ported acquisitions." setRecordCount

@eh setRecordSize(a::InstrumentAlazar, preTriggerSamples, postTriggerSamples) =
    ccall((:AlazarSetRecordSize,ats), U32, (U32,U32,U32), a.handle, preTriggerSamples, postTriggerSamples)
@doc "Configures the acquisition records size." setRecordSize

@eh setTriggerDelaySamples(a::InstrumentAlazar, delay_samples) =
    ccall((:AlazarSetTriggerDelay,ats),U32,(U32,U32),a.handle, delay_samples)
@doc "Configures the trigger delay in samples." setTriggerDelaySamples

@eh setTriggerOperation(a::InstrumentAlazar, operation, engine1, source1, slope1, level1, engine2, source2, slope2, level2) =
    ccall((:AlazarSetTriggerOperation,ats),U32,(U32, U32, U32, U32, U32, U32, U32, U32, U32, U32),
      a.handle, operation, engine1, source1, slope1, level1, engine2, source2, slope2, level2)
@doc "Set trigger operation." setTriggerOperation

@eh setTriggerTimeoutTicks(a::InstrumentAlazar, timeout_clocks) =
    ccall((:AlazarSetTriggerTimeOut,ats), U32, (U32,U32), a.handle, timeout_clocks)
@doc "Configures the trigger timeout in ticks (10 us units). Fractional ticks get rounded up. 0 means wait forever." setTriggerTimeoutTicks

function setTriggerTimeout(a::InstrumentAlazar, timeout_s)
    setTriggerTimeoutTicks(a, U32(ceil(timeout_s * 1.e5)))
    a.triggerTimeoutTicks = U32(ceil(timeout_s * 1.e5))
end
@doc "Configures the trigger timeout in seconds, rounded up to the nearest 10 us. 0 means wait forever." setTriggerTimeout

@eh sleepDevice(a::InstrumentAlazar, sleepState) =
    ccall((:AlazarSleepDevice,ats), U32, (U32,U32), a.handle, sleepState)
@doc "Control power to ADC devices" sleepDevice

@eh startCapture(a::InstrumentAlazar) = ccall((:AlazarStartCapture,ats),U32,(U32,),a.handle)
@doc "Starts the acquisition." startCapture

@eh triggered(a::InstrumentAlazar) = ccall((:AlazarTriggered,ats),U32,(U32,),a.handle)
@doc "Determine if a board has triggered during the current acquisition." triggered

@eh waitAsyncBufferComplete(a::InstrumentAlazar, buffer, timeout_ms) =
    ccall((:AlazarWaitAsyncBufferComplete,ats),U32,(U32,Ptr{Void},U32),a.handle, buffer, timeout_ms)
@doc "Blocks until the board confirms that buffer is filled with data." waitAsyncBufferComplete

export AlazarATS9360
"""
ATS9360 is a concrete subtype of InstrumentAlazar.
"""
type AlazarATS9360 <: InstrumentAlazar

    systemId::Culong
    boardId::Culong
    handle::Culong

    clockSource::U32
    sampleRate::U32
    clockSlope::U32
    decimation::U32

    coupling::U32
    triggerRange::U32

    triggerOperation::U32
    triggerJChannel::U32
    triggerJSlope::U32
    triggerJLevel::U32
    triggerKChannel::U32
    triggerKSlope::U32
    triggerKLevel::U32

    triggerDelaySamples::U32
    triggerTimeoutTicks::U32

    auxIOMode::U32
    auxParam::U32

    acquisitionLength::Float64
    acquisitionChannel::U32
    channelCount::U32

    packingA::Clong
    packingB::Clong

    bufferArray::Array{DMABuffer{UInt16},1}

    # defaults
    inputControlDefaults(a::AlazarATS9360) = begin
        invoke(inputControl,(InstrumentAlazar,Any,Any,Any,Any), a, CHANNEL_A, DC_COUPLING, INPUT_RANGE_PM_400_MV, IMPEDANCE_50_OHM)
        invoke(inputControl,(InstrumentAlazar,Any,Any,Any,Any), a, CHANNEL_B, DC_COUPLING, INPUT_RANGE_PM_400_MV, IMPEDANCE_50_OHM)
        # There are no internal variables in the AlazarATS9360 type because these are
        # the only possible options for this particular instrument!
    end

    captureClockDefaults(a::AlazarATS9360) = begin
        setCaptureClock(a, INTERNAL_CLOCK, SAMPLE_RATE_1000MSPS, CLOCK_EDGE_RISING, 0)
        a.clockSource = INTERNAL_CLOCK
        a.sampleRate = SAMPLE_RATE_1000MSPS
        a.clockSlope = CLOCK_EDGE_RISING
        a.decimation = U32(0)
    end

    triggerOperationDefaults(a::AlazarATS9360) = begin
        setTriggerOperation(a,
                            Alazar.TRIG_ENGINE_OP_J,
                            Alazar.TRIG_ENGINE_J,
                            Alazar.TRIG_CHAN_A,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            150,
                            Alazar.TRIG_ENGINE_K,
                            Alazar.TRIG_DISABLE,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            128)
        a.triggerOperation = TRIG_ENGINE_OP_J
        a.triggerJChannel  = TRIG_CHAN_A
        a.triggerJSlope    = TRIGGER_SLOPE_POSITIVE
        a.triggerJLevel    = U32(150)
        a.triggerKChannel  = TRIG_DISABLE
        a.triggerKSlope    = TRIGGER_SLOPE_POSITIVE
        a.triggerKLevel    = U32(128)
    end

    externalTriggerDefaults(a::AlazarATS9360) = begin
        setExternalTrigger(a, DC_COUPLING, ETR_5V)
        a.coupling = DC_COUPLING
        a.triggerRange = ETR_5V
    end

    triggerDelayDefaults(a::AlazarATS9360) = begin
        setTriggerDelaySamples(a, U32(0))
        a.triggerDelaySamples = U32(0)
    end

    triggerTimeoutDefaults(a::AlazarATS9360) = setTriggerTimeoutTicks(a, U32(0))

    auxIODefaults(a::AlazarATS9360) = configureAuxIO(a, AUX_OUT_TRIGGER, U32(0))

    # packingDefaults(a::AlazarATS9360) = setDataPacking(a,BothChannels,DefaultPacking)

    acquisitionDefaults(a::AlazarATS9360) = begin
        setAcquisitionLength(a,1.0) #1s
        setAcquisitionChannel(a,BothChannels)
    end

    AlazarATS9360() = AlazarATS9360(1,1)
    AlazarATS9360(a,b) = begin
        handle = ccall((:AlazarGetBoardBySystemID,ats),Culong,(Culong,Culong),convert(Culong,a),convert(Culong,b))
        if (handle == 0)
            error("Board $a.$b not found.")
        end
        btype = ccall((:AlazarGetBoardKind,ats),Culong,(Culong,),handle)
        if (btype != ATS9360)
            error("Board at $a.$b is not an ATS9360.")
        end
        at = new()
        at.systemId = a
        at.boardId = b
        at.handle = handle
        at.bufferArray = Array{DMABuffer{UInt16},1}()
        inputControlDefaults(at)
        captureClockDefaults(at)
        triggerOperationDefaults(at)
        externalTriggerDefaults(at)
        triggerDelayDefaults(at)
        triggerTimeoutDefaults(at)
        auxIODefaults(at)
        #packingDefaults(at)
        acquisitionDefaults(at)
        return at
    end
end
Base.show(io::IO, ins::InstrumentAlazar) = print(io, "ATS9360: SystemId $(ins.systemId), BoardId $(ins.boardId)")

responses = Dict(
    :InstrumentCoupling     => Dict(AC_COUPLING             => :AC,
                                    DC_COUPLING             => :DC),

	:InstrumentTriggerSlope => Dict(TRIGGER_SLOPE_POSITIVE 	=> :RisingTrigger,
									TRIGGER_SLOPE_NEGATIVE 	=> :FallingTrigger),

    :InstrumentClockSlope   => Dict(CLOCK_EDGE_RISING       => :RisingClock,
                                    CLOCK_EDGE_FALLING      => :FallingClock),

	:InstrumentClockSource  => Dict(INTERNAL_CLOCK	         => :InternalClock,
								    EXTERNAL_CLOCK_10MHz_REF => :ExternalClock),

    :InstrumentSampleRate   => Dict(SAMPLE_RATE_1KSPS    =>  :Rate1kSps,
                                    SAMPLE_RATE_2KSPS    =>  :Rate2kSps,
                                    SAMPLE_RATE_5KSPS    =>  :Rate5kSps,
                                    SAMPLE_RATE_10KSPS   =>  :Rate10kSps,
                                    SAMPLE_RATE_20KSPS   =>  :Rate20kSps,
                                    SAMPLE_RATE_50KSPS   =>  :Rate50kSps,
                                    SAMPLE_RATE_100KSPS  =>  :Rate100kSps,
                                    SAMPLE_RATE_200KSPS  =>  :Rate200kSps,
                                    SAMPLE_RATE_500KSPS  =>  :Rate500kSps,
                                    SAMPLE_RATE_1MSPS    =>  :Rate1MSps,
                                    SAMPLE_RATE_2MSPS    =>  :Rate2MSps,
                                    SAMPLE_RATE_5MSPS    =>  :Rate5MSps,
                                    SAMPLE_RATE_10MSPS   =>  :Rate10MSps,
                                    SAMPLE_RATE_20MSPS   =>  :Rate20MSps,
                                    SAMPLE_RATE_50MSPS   =>  :Rate50MSps,
                                    SAMPLE_RATE_100MSPS  =>  :Rate100MSps,
                                    SAMPLE_RATE_200MSPS  =>  :Rate200MSps,
                                    SAMPLE_RATE_500MSPS  =>  :Rate500MSps,
                                    SAMPLE_RATE_800MSPS  =>  :Rate800MSps,
                                    SAMPLE_RATE_1000MSPS =>  :Rate1000MSps,
                                    SAMPLE_RATE_1200MSPS =>  :Rate1200MSps,
                                    SAMPLE_RATE_1500MSPS =>  :Rate1500MSps,
                                    SAMPLE_RATE_1800MSPS =>  :Rate1800MSps),

    :AlazarChannel          => Dict(CHANNEL_A             =>  :ChannelA,
                                    CHANNEL_B             =>  :ChannelB,
                                    CHANNEL_A | CHANNEL_B =>  :BothChannels),

    :AlazarAux              => Dict(AUX_OUT_TRIGGER       =>  :AuxOutputTrigger,
                                    AUX_IN_TRIGGER_ENABLE =>  :AuxInputTriggerEnable,
                                    AUX_OUT_PACER         =>  :AuxOutputPacer,
                                    AUX_IN_AUXILIARY      =>  :AuxDigitalInput,
                                    AUX_OUT_SERIAL_DATA   =>  :AuxDigitalOutput),

    :AlazarDataPacking      => Dict(PACK_DEFAULT            => :DefaultPacking,
                                    PACK_8_BITS_PER_SAMPLE  => :Pack8Bits,
                                    PACK_12_BITS_PER_SAMPLE => :Pack12Bits)
)

PainterQB.generateResponseHandlers(AlazarATS9360, responses)
Rate1GSps(ins::AlazarATS9360) = Rate1000MSps(ins::AlazarATS9360)
Rate1GSps(ins::AlazarATS9360, state) = Rate1000MSps(ins,state)

# sampleRate(rate::DataType) = begin
#     @assert rate <: InstrumentSampleRate "$rate <: InstrumentSampleRate"
#     sampleRate(rate())
# end
export sampleRate
sampleRate(::Rate1kSps) = 1e3 |> U32
sampleRate(::Rate2kSps) = 2e3 |> U32
sampleRate(::Rate5kSps) = 5e3 |> U32
sampleRate(::Rate10kSps) = 1e4 |> U32
sampleRate(::Rate20kSps) = 2e4 |> U32
sampleRate(::Rate50kSps) = 5e4 |> U32
sampleRate(::Rate100kSps) = 1e5 |> U32
sampleRate(::Rate200kSps) = 2e5 |> U32
sampleRate(::Rate500kSps) = 5e5 |> U32
sampleRate(::Rate1MSps)  = 1e6 |> U32
sampleRate(::Rate2MSps)  = 2e6 |> U32
sampleRate(::Rate5MSps)  = 5e6 |> U32
sampleRate(::Rate10MSps) = 1e7 |> U32
sampleRate(::Rate20MSps) = 2e7 |> U32
sampleRate(::Rate50MSps) = 5e7 |> U32
sampleRate(::Rate100MSps) = 1e8 |> U32
sampleRate(::Rate200MSps) = 2e8 |> U32
sampleRate(::Rate500MSps) = 5e8 |> U32
sampleRate(::Rate800MSps) = 8e8 |> U32
sampleRate(::Rate1000MSps) = 1e9 |> U32
sampleRate(::Rate1200MSps) = 12e8 |> U32
sampleRate(::Rate1500MSps) = 15e8 |> U32
sampleRate(::Rate1800MSps) = 18e8 |> U32

function sampleRate(a::AlazarATS9360)
    a.sampleRate > 0x80 ? a.sampleRate : sampleRate(InstrumentSampleRate(a,a.sampleRate))::U32
end

export setSampleRate, setClockSlope, setAuxSoftwareTriggerEnabled
export setAcquisitionLength, setDataPacking, setAcquisitionChannel
export acquisitionLength, samplesPerBuffer, channelCount, bytesPerBuffer
export samplesPerAcquisition, bytesPerSample, bufferCount

function inputControl(a::AlazarATS9360, x...)
    warning("This function has been no-op'd since there are no choices for the ATS9360.")
end

# Set by object
function setSampleRate(a::AlazarATS9360, rate::InstrumentSampleRate)
    r = setCaptureClock(a, INTERNAL_CLOCK, rate.state, a.clockSlope, 0)
    a.clockSource = INTERNAL_CLOCK
    a.sampleRate = rate.state
    a.decimation = 0
    r
end

# Set by data type
function setSampleRate(a::AlazarATS9360, rate::DataType)
    @assert rate <: InstrumentSampleRate "$rate <: InstrumentSampleRate"
    val = rate(a).state
    r = setCaptureClock(a, INTERNAL_CLOCK, val, a.clockSlope, 0)
    a.clockSource = INTERNAL_CLOCK
    a.sampleRate = val
    a.decimation = 0
    r
end

function setSampleRate(a::AlazarATS9360, rate::Real)
    actualRate = U32(fld(rate,1e6)*1e6)
    if (rate != actualRate)
        warning("Rate must be in increments of 1 MHz. Setting ",actualRate," Hz")
    end
    r = setCaptureClock(a, EXTERNAL_CLOCK_10MHz_REF, actualRate, a.clockSlope, 1)
    a.clockSource = EXTERNAL_CLOCK_10MHz_REF
    a.sampleRate = actualRate
    a.decimation = 1
    r
end

function setClockSlope(a::AlazarATS9360, slope::InstrumentClockSlope)
    r = setCaptureClock(a, a.clockSource, a.sampleRate, slope.state, a.decimation)
    a.clockSlope = slope.state
    r
end

function setClockSlope(a::AlazarATS9360, slope::DataType)
    @assert slope <: InstrumentClockSlope "$rate <: InstrumentClockSlope"
    val = slope(a).state
    r = setCaptureClock(a, a.clockSource, a.sampleRate, val, a.decimation)
    a.clockSlope = val
    r
end

function configureAuxIO(a::AlazarATS9360, aux::DataType, x...)
    @assert aux <: AlazarAux "$aux <: AlazarAux"
    configureAuxIO(a, aux(a), x...)
end

function configureAuxIO(a::AlazarATS9360, aux::Union{AuxOutputTrigger,AuxDigitalInput})
    r = configureAuxIO(a, aux.state, U32(0))
    a.auxIOMode = aux.state
    a.auxParam = U32(0)
    r
end #of module

function configureAuxIO(a::AlazarATS9360, aux::AuxInputTriggerEnable, trigSlope::U32)
    r = configureAuxIO(a, aux.state, trigSlope)
    a.auxIOMode = aux.state
    a.auxParam = trigSlope
    r
end

function configureAuxIO(a::AlazarATS9360, aux::AuxInputTriggerEnable,
                                    trigSlope::InstrumentTriggerSlope)
    r = configureAuxIO(a, aux.state, trigSlope.state)
    a.auxIOMode = aux.state
    a.auxParam = trigSlope.state
    r
end

function configureAuxIO(a::AlazarATS9360, aux::AuxOutputPacer, divider::Integer)
    @assert (divider > 2) "Clock divider must be greater than 2."
    r = configureAuxIO(a, aux.state, U32(divider))
    a.auxIOMode = aux.state
    a.auxParam = divider
    r
end

function configureAuxIO(a::AlazarATS9360, aux::AuxDigitalOutput, level::Integer)
    @assert (level != 0 || level != 1) "Level must be low (0) or high (1)."
    r = configureAuxIO(a, aux.state, U32(level))
    a.auxIOMode = aux.state
    a.auxParam = level
    r
end

function setAuxSoftwareTriggerEnabled(a::AlazarATS9360, d::DataType)
    @assert d <: InstrumentBoolean "$d <: InstrumentBoolean"
    setAuxSoftwareTriggerEnabled(a,d(a))
end

function setAuxSoftwareTriggerEnabled(a::AlazarATS9360, ::Yes)
    r = configureAuxIO(a, a.auxIOMode, a.auxParam | AUX_OUT_TRIGGER_ENABLE)
    a.auxParam = a.auxParam | AUX_OUT_TRIGGER_ENABLE
    r
end

function setAuxSoftwareTriggerEnabled(a::AlazarATS9360, ::No)
    r = configureAuxIO(a, a.auxIOMode, a.auxParam & ~AUX_OUT_TRIGGER_ENABLE)
    a.auxParam = a.auxParam & ~AUX_OUT_TRIGGER_ENABLE
    r
end

function setAuxSoftwareTriggerEnabled(a::AlazarATS9360, x::Bool)
    setAuxSoftwareTriggerEnabled(a, (x==true) ? Yes : No)
end

function setAcquisitionLength(a::AlazarATS9360, l::Real)
    a.acquisitionLength = convert(Float64,l)
end

acquisitionLength(a::AlazarATS9360) = a.acquisitionLength
bytesPerSample(a::InstrumentAlazar) = begin
    (a,b) = getChannelInfo(a)
    U32(fld((b + 7), 8))
end
samplesPerBuffer(a::AlazarATS9360) = U32(409600)
channelCount(a::AlazarATS9360) = a.channelCount
bytesPerBuffer(a::AlazarATS9360) = U32(bytesPerSample(a) * samplesPerBuffer(a) * channelCount(a))
samplesPerAcquisition(a::AlazarATS9360) = Culonglong(floor(sampleRate(a) * acquisitionLength(a) + 0.5))
bufferCount(a::AlazarATS9360) = U32(4)

# function setDataPacking(a::AlazarATS9360, ch::DataType, pack::DataType)
#     @assert ch <: AlazarChannel "$ch <: AlazarChannel"
#     setDataPacking(a, (ch)(a), (pack)(a))
# end
#
# function setDataPacking(a::AlazarATS9360, ch::ChannelA, pack::AlazarDataPacking)
#     setParameter(a, ch.state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingA = pack.state
# end
#
# function setDataPacking(a::AlazarATS9360, ch::ChannelB, pack::AlazarDataPacking)
#     setParameter(a, ch.state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingB = pack.state
# end
#
# function setDataPacking(a::AlazarATS9360, ch::BothChannels, pack::AlazarDataPacking)
#     setParameter(a, ChannelA(a).state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingA = pack.state
#     setParameter(a, ChannelB(a).state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingB = pack.state
# end

function setAcquisitionChannel(a::AlazarATS9360, ch::AlazarChannel)
    a.acquisitionChannel = ch.state
    a.channelCount = 1
end

function setAcquisitionChannel(a::AlazarATS9360, ch::BothChannels)
    a.acquisitionChannel = ch.state
    a.channelCount = 2
end

function setAcquisitionChannel(a::AlazarATS9360, ch::DataType)
    setAcquisitionChannel(a, (ch)(a))
end

function acquisitionChannel(a::AlazarATS9360)
    AlazarChannel(a,a.acquisitionChannel)
end

end
