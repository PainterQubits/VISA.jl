"""
Configuration/Acquisition/Generation Command Set
"""
# sets and gets
const NUMBER_OF_RECORDS                 = U32(0x10000001)
const PRETRIGGER_AMOUNT                 = U32(0x10000002)
const RECORD_LENGTH                     = U32(0x10000003)
const TRIGGER_ENGINE                    = U32(0x10000004)
const TRIGGER_DELAY                     = U32(0x10000005)
const TRIGGER_TIMEOUT                   = U32(0x10000006)
const SAMPLE_RATE                       = U32(0x10000007)
const CONFIGURATION_MODE                = U32(0x10000008)
const DATA_WIDTH                        = U32(0x10000009)
const SAMPLE_SIZE                       = DATA_WIDTH
const AUTO_CALIBRATE                    = U32(0x1000000A)
const TRIGGER_XXXXX                     = U32(0x1000000B)
const CLOCK_SOURCE                      = U32(0x1000000C)
const CLOCK_SLOPE                       = U32(0x1000000D)
const IMPEDANCE                         = U32(0x1000000E)
const INPUT_RANGE                       = U32(0x1000000F)
const COUPLING                          = U32(0x10000010)
const MAX_TIMEOUTS_ALLOWED              = U32(0x10000011)
const OPERATING_MODE                    = U32(0x10000012)
const CLOCK_DECIMATION_EXTERNAL         = U32(0x10000013)
const LED_CONTROL                       = U32(0x10000014)
const ATTENUATOR_RELAY                  = U32(0x10000018)
const EXT_TRIGGER_COUPLING              = U32(0x1000001A)
const EXT_TRIGGER_ATTENUATOR_RELAY      = U32(0x1000001C)
const TRIGGER_ENGINE_SOURCE             = U32(0x1000001E)
const TRIGGER_ENGINE_SLOPE              = U32(0x10000020)
const SEND_DAC_VALUE                    = U32(0x10000021)
const SLEEP_DEVICE                      = U32(0x10000022)
const GET_DAC_VALUE                     = U32(0x10000023)
const GET_SERIAL_NUMBER                 = U32(0x10000024)
const GET_FIRST_CAL_DATE                = U32(0x10000025)
const GET_LATEST_CAL_DATE               = U32(0x10000026)
const GET_LATEST_TEST_DATE              = U32(0x10000027)
const SEND_RELAY_VALUE                  = U32(0x10000028)
const GET_LATEST_CAL_DATE_MONTH         = U32(0x1000002D)
const GET_LATEST_CAL_DATE_DAY           = U32(0x1000002E)
const GET_LATEST_CAL_DATE_YEAR          = U32(0x1000002F)
const GET_PCIE_LINK_SPEED               = U32(0x10000030)
const GET_PCIE_LINK_WIDTH               = U32(0x10000031)
const SETGET_ASYNC_BUFFSIZE_BYTES       = U32(0x10000039)
const SETGET_ASYNC_BUFFCOUNT            = U32(0x10000040)
const SET_DATA_FORMAT                   = U32(0x10000041)
const GET_DATA_FORMAT                   = U32(0x10000042)
const DATA_FORMAT_UNSIGNED              = U32(0x0)
const DATA_FORMAT_SIGNED                = U32(0x1)
const SET_SINGLE_CHANNEL_MODE           = U32(0x10000043)
const GET_SAMPLES_PER_TIMESTAMP_CLOCK   = U32(0x10000044)
const GET_RECORDS_CAPTURED              = U32(0x10000045)
const GET_MAX_PRETRIGGER_SAMPLES        = U32(0x10000046)
const SET_ADC_MODE                      = U32(0x10000047)
const ADC_MODE_DEFAULT                  = U32(0x0)
const ADC_MODE_DES                      = U32(0x1)
const ADC_MODE_DES_WIDEBAND             = U32(0x2)
const ADC_MODE_RESET_ENABLE             = U32(0x8001)      # not clear if should be U32
const ADC_MODE_RESET_DISABLE            = U32(0x8002)      # not clear if should be U32
const ECC_MODE                          = U32(0x10000048)
const ECC_DISABLE                       = U32(0x0)         # not clear if should be U32
const ECC_ENABLE                        = U32(0x1)         # not clear if should be U32
const GET_AUX_INPUT_LEVEL               = U32(0x10000049)
const AUX_INPUT_LOW                     = U32(0x0)         # not clear if should be U32
const AUX_INPUT_HIGH                    = U32(0x1)         # not clear if should be U32
const EXT_TRIGGER_IMPEDANCE             = U32(0x10000065)
const EXT_TRIG_50_OHMS                  = U32(0x0)         # not clear if should be UL
const EXT_TRIG_300_OHMS                 = U32(0x1)         # not clear if should be UL
const GET_CHANNELS_PER_BOARD            = U32(0x10000070)
const GET_CPF_DEVICE                    = U32(0x10000071)
const PACK_MODE                         = U32(0x10000072)
const PACK_DEFAULT                      = Clong(0x0)
const PACK_8_BITS_PER_SAMPLE            = Clong(0x1)
const PACK_12_BITS_PER_SAMPLE           = Clong(0x2)
const GET_FPGA_TEMPERATURE              = U32(0x10000080)
const API_FLAGS                         = U32(0x10000090)
const API_ENABLE_TRACE                  = U32(0x1)         # not clear if should be UL

# gets board specific parameters
const MEMORY_SIZE                       = U32(0x1000002A)
const MEMORY_SIZE_MSAMPLES              = U32(0x1000004A)
const BOARD_TYPE                        = U32(0x1000002B)
const ASOPC_TYPE                        = U32(0x1000002C)
const GET_BOARD_OPTIONS_LOW             = U32(0x10000037)
const GET_BOARD_OPTIONS_HIGH            = U32(0x10000038)
const OPTION_STREAMING_DMA              = <<(U32(1),0)
const OPTION_EXTERNAL_CLOCK             = <<(U32(1),1)
const OPTION_DUAL_PORT_MEMORY           = <<(U32(1),2)
const OPTION_180MHZ_OSCILLATOR          = <<(U32(1),3)
const OPTION_LVTTL_EXT_CLOCK            = <<(U32(1),4)
const OPTION_SW_SPI                     = <<(U32(1),5)
const OPTION_ALT_INPUT_RANGES           = <<(U32(1),6)
const OPTION_VARIABLE_RATE_10MHZ_PLL    = <<(U32(1),7)
const OPTION_2GHZ_ADC                   = <<(U32(1),8)
const OPTION_DUAL_EDGE_SAMPLING         = <<(U32(1),9)
const OPTION_OEM_FPGA                   = <<(U32(1),47)

# sets and gets
# The transfer offset is defined as the place to start
# the transfer relative to trigger. The value is signed.
# -------TO>>>T>>>>>>>>>TE------------
const TRANSFER_OFFET                    = U32(0x10000030)  # typo in C API?
const TRANSFER_LENGTH                   = U32(0x10000031)

# Transfer related constants
const TRANSFER_RECORD_OFFSET            = U32(0x10000032)
const TRANSFER_NUM_OF_RECORDS           = U32(0x10000033)
const TRANSFER_MAPPING_RATIO            = U32(0x10000034)

# only gets
const TRIGGER_ADDRESS_AND_TIMESTAMP     = U32(0x10000035)

# MASTER/SLAVE CONTROL sets/gets
const MASTER_SLAVE_INDEPENDENT          = U32(0x10000036)

# boolean gets
const TRIGGERED                         = U32(0x10000040)
const BUSY                              = U32(0x10000041)
const WHO_TRIGGERED                     = U32(0x10000042)
const GET_ASYNC_BUFFERS_PENDING         = U32(0x10000050)
const GET_ASYNC_BUFFERS_PENDING_FULL    = U32(0x10000051)
const GET_ASYNC_BUFFERS_PENDING_EMPTY   = U32(0x10000052)
const ACF_SAMPLES_PER_RECORD            = U32(0x10000060)
const ACF_RECORDS_TO_AVERAGE            = U32(0x10000061)
const ACF_MODE                          = U32(0x10000062)

"""
Sample rates that the internal clock of a board can generate.

Note: Available sample rates for a given board form a subset of
this class' members. Please see your board's specification as well
as the ATS-SDK manual for more information.
"""
# Sample rate values
const SAMPLE_RATE_1KSPS     = U32(0x1)
const SAMPLE_RATE_2KSPS     = U32(0x2)
const SAMPLE_RATE_5KSPS     = U32(0x5)
const SAMPLE_RATE_10KSPS    = U32(0x8)
const SAMPLE_RATE_20KSPS    = U32(0xA)
const SAMPLE_RATE_50KSPS    = U32(0xC)
const SAMPLE_RATE_100KSPS   = U32(0xE)
const SAMPLE_RATE_200KSPS   = U32(0x10)
const SAMPLE_RATE_500KSPS   = U32(0x12)
const SAMPLE_RATE_1MSPS     = U32(0x14)
const SAMPLE_RATE_2MSPS     = U32(0x18)
const SAMPLE_RATE_5MSPS     = U32(0x1A)
const SAMPLE_RATE_10MSPS    = U32(0x1C)
const SAMPLE_RATE_20MSPS    = U32(0x1E)
const SAMPLE_RATE_25MSPS    = U32(0x21)
const SAMPLE_RATE_50MSPS    = U32(0x22)
const SAMPLE_RATE_100MSPS   = U32(0x24)
const SAMPLE_RATE_125MSPS   = U32(0x25)
const SAMPLE_RATE_160MSPS   = U32(0x26)
const SAMPLE_RATE_180MSPS   = U32(0x27)
const SAMPLE_RATE_200MSPS   = U32(0x28)
const SAMPLE_RATE_250MSPS   = U32(0x2B)
const SAMPLE_RATE_400MSPS   = U32(0x2D)
const SAMPLE_RATE_500MSPS   = U32(0x30)
const SAMPLE_RATE_800MSPS   = U32(0x32)
const SAMPLE_RATE_1000MSPS  = U32(0x35)
const SAMPLE_RATE_1GSPS     = SAMPLE_RATE_1000MSPS
const SAMPLE_RATE_1200MSPS  = U32(0x37)
const SAMPLE_RATE_1500MSPS  = U32(0x3A)
const SAMPLE_RATE_1600MSPS  = U32(0x3B)
const SAMPLE_RATE_1800MSPS  = U32(0x3D)
const SAMPLE_RATE_2000MSPS  = U32(0x3F)
const SAMPLE_RATE_2GSPS     = SAMPLE_RATE_2000MSPS
const SAMPLE_RATE_2400MSPS  = U32(0x6A)
const SAMPLE_RATE_3000MSPS  = U32(0x75)
const SAMPLE_RATE_3GSPS     = SAMPLE_RATE_3000MSPS
const SAMPLE_RATE_3600MSPS  = U32(0x7B)
const SAMPLE_RATE_4000MSPS  = U32(0x80)
const SAMPLE_RATE_4GSPS     = SAMPLE_RATE_4000MSPS

# User-defined sample rate; used with External Clock
const SAMPLE_RATE_USER_DEF  = U32(0x40)

"""
ATS665 Specific Setting for using the PLL.
The base value can be used to create a PLL frequency
in a simple manner.

Ex.
      105 MHz = PLL_10MHZ_REF_100MSPS_BASE + 5000000
      120 MHz = PLL_10MHZ_REF_100MSPS_BASE + 20000000
"""
const PLL_10MHZ_REF_100MSPS_BASE = U32(0x05F5E100)

# ATS665 Specific Decimation constants
const DECIMATE_BY_8              = U32(0x00000008)
const DECIMATE_BY_64             = U32(0x00000040)

#impedancevalues #suchresistance
const IMPEDANCE_1M_OHM           = U32(0x00000001)
const IMPEDANCE_50_OHM           = U32(0x00000002)
const IMPEDANCE_75_OHM           = U32(0x00000004)
const IMPEDANCE_300_OHM          = U32(0x00000008)

"""
Types of clocks that a board can use for acquiring data.
Note: Available sources for a given board form a subset of this
class' members. Please see your board's specification as well as
the ATS-SDK manual for more information.
"""
const INTERNAL_CLOCK            = U32(0x1)
const EXTERNAL_CLOCK            = U32(0x2)
const FAST_EXTERNAL_CLOCK       = U32(0x2)
const MEDIUM_EXTERNAL_CLOCK     = U32(0x3)
const SLOW_EXTERNAL_CLOCK       = U32(0x4)
const EXTERNAL_CLOCK_AC         = U32(0x5)
const EXTERNAL_CLOCK_DC         = U32(0x6)
const EXTERNAL_CLOCK_10MHz_REF  = U32(0x7)
const INTERNAL_CLOCK_10MHz_REF  = U32(0x8)    # 0x8 to 0x12 not ULd in C API
const EXTERNAL_CLOCK_10MHz_PXI  = U32(0xA)
const INTERNAL_CLOCK_DIV_4      = U32(0xF)
const INTERNAL_CLOCK_DIV_5      = U32(0x10)
const MASTER_CLOCK              = U32(0x11)
const INTERNAL_CLOCK_SET_VCO    = U32(0x12)

"""
Direction of the edge from the external clock signal that the board
syncrhonises with.
"""
const CLOCK_EDGE_RISING     = U32(0x0)
const CLOCK_EDGE_FALLING    = U32(0x1)

"""
Board input ranges (amplitudes) identifiers. PM stands for
plus/minus.

Note: Available input ranges for a given board *and* a given
configuration form a subset of this class' members. Please see
your board's specification as well as the ATS-SDK manual for more
information.
"""
const INPUT_RANGE_PM_20_MV	= U32(0x00000001)     # was not in Python API
const INPUT_RANGE_PM_40_MV  = U32(0x2)
const INPUT_RANGE_PM_50_MV  = U32(0x3)
const INPUT_RANGE_PM_80_MV  = U32(0x4)
const INPUT_RANGE_PM_100_MV = U32(0x5)
const INPUT_RANGE_PM_200_MV = U32(0x6)
const INPUT_RANGE_PM_400_MV = U32(0x7)
const INPUT_RANGE_PM_500_MV = U32(0x8)
const INPUT_RANGE_PM_800_MV = U32(0x9)
const INPUT_RANGE_PM_1_V    = U32(0xA)
const INPUT_RANGE_PM_2_V    = U32(0xB)
const INPUT_RANGE_PM_4_V    = U32(0xC)
const INPUT_RANGE_PM_5_V    = U32(0xD)
const INPUT_RANGE_PM_8_V    = U32(0xE)
const INPUT_RANGE_PM_10_V   = U32(0xF)
const INPUT_RANGE_PM_20_V   = U32(0x10)
const INPUT_RANGE_PM_40_V   = U32(0x11)
const INPUT_RANGE_PM_16_V   = U32(0x12)
const INPUT_RANGE_HIFI      = U32(0x20)
const INPUT_RANGE_PM_1_V_25 = U32(0x21)
const INPUT_RANGE_PM_2_V_5  = U32(0x25)
const INPUT_RANGE_PM_125_MV = U32(0x28)
const INPUT_RANGE_PM_250_MV = U32(0x30)

"""Coupling types identifiers for all boards input"""
const AC_COUPLING           = U32(1)
const DC_COUPLING           = U32(2)

"""Trigger engine identifiers."""
const TRIG_ENGINE_J         = U32(0)
const TRIG_ENGINE_K         = U32(1)

"""Trigger engine operation identifiers."""
const TRIG_ENGINE_OP_J            = U32(0)
const TRIG_ENGINE_OP_K            = U32(1)
const TRIG_ENGINE_OP_J_OR_K       = U32(2)
const TRIG_ENGINE_OP_J_AND_K      = U32(3)
const TRIG_ENGINE_OP_J_XOR_K      = U32(4)
const TRIG_ENGINE_OP_J_AND_NOT_K  = U32(5)
const TRIG_ENGINE_OP_NOT_J_AND_K  = U32(6)

"""Types of input that the board can trig on."""
const TRIG_CHAN_A   = U32(0x00000000)
const TRIG_CHAN_B   = U32(0x00000001)
const TRIG_CHAN_C   = U32(0x00000004)
const TRIG_CHAN_D   = U32(0x00000005)
const TRIG_CHAN_E   = U32(0x00000006)
const TRIG_CHAN_F   = U32(0x00000007)
const TRIG_CHAN_G   = U32(0x00000008)
const TRIG_CHAN_H   = U32(0x00000009)
const TRIG_CHAN_I   = U32(0x0000000A)
const TRIG_CHAN_J   = U32(0x0000000B)
const TRIG_CHAN_K   = U32(0x0000000C)
const TRIG_CHAN_L   = U32(0x0000000D)
const TRIG_CHAN_M   = U32(0x0000000E)
const TRIG_CHAN_N   = U32(0x0000000F)
const TRIG_CHAN_O   = U32(0x00000010)
const TRIG_CHAN_P   = U32(0x00000011)
const TRIG_PXI_STAR = U32(0x00000100)
const TRIG_EXTERNAL = U32(0x00000002)
const TRIG_DISABLE  = U32(0x00000003)

"""Edge of the external trigger signal that the board syncrhonises with."""
const TRIGGER_SLOPE_POSITIVE = U32(1)
const TRIGGER_SLOPE_NEGATIVE = U32(2)

"""
Board input channel identifiers

Note: The channels available for a given board form a subset of this
class' members. Please see your board's specification as well as
the ATS-SDK manual for more information.
"""
const CHANNEL_ALL   = U8(0x0000)
const CHANNEL_A     = U8(0x0001)
const CHANNEL_B     = U8(0x0002)
const CHANNEL_C     = U8(0x0004)
const CHANNEL_D     = U8(0x0008)
const CHANNEL_E     = U8(0x0010)
const CHANNEL_F     = U8(0x0020)
const CHANNEL_G     = U8(0x0040)
const CHANNEL_H     = U8(0x0080)
# const CHANNEL_I     = U8(0x0100)
# const CHANNEL_J     = U8(0x0200)
# const CHANNEL_K     = U8(0x0400)
# const CHANNEL_L     = U8(0x0800)
# const CHANNEL_M     = U8(0x1000)
# const CHANNEL_N     = U8(0x2000)
# const CHANNEL_O     = U8(0x4000)
# const CHANNEL_P     = U8(0x8000)
#
# channels = [
#     CHANNEL_A,
#     CHANNEL_B,
#     CHANNEL_C,
#     CHANNEL_D,
#     CHANNEL_E,
#     CHANNEL_F,
#     CHANNEL_G,
#     CHANNEL_H,
#     CHANNEL_I,
#     CHANNEL_J,
#     CHANNEL_K,
#     CHANNEL_L,
#     CHANNEL_M,
#     CHANNEL_N,
#     CHANNEL_O,
#     CHANNEL_P
# ]

# Master/slave configuration
const BOARD_IS_INDEPENDENT  = U32(0x00000000)
const BOARD_IS_MASTER       = U32(0x00000001)
const BOARD_IS_SLAVE        = U32(0x00000002)
const BOARD_IS_LAST_SLAVE   = U32(0x00000003)

# LED control
const LED_OFF               = U32(0x00000000)
const LED_ON                = U32(0x00000001)

# Attenuator relay
const AR_X1                 = U32(0x00000000)
const AR_DIV40              = U32(0x00000001)

# External Trigger Attenuator Relay
const ETR_DIV5              = U32(0x00000000)
const ETR_X1                = U32(0x00000001)
const ETR_5V                = U32(0x00000000)
const ETR_1V                = U32(0x00000001)
const ETR_TTL               = U32(0x00000002)
const ETR_2V5               = U32(0x00000003)

# Device sleep state
const POWER_OFF             = U32(0x00000000)
const POWER_ON              = U32(0x00000001)

# Software events control
const SW_EVENTS_OFF         = U32(0x00000000)
const SW_EVENTS_ON          = U32(0x00000001)

# Timestamp value reset control
const TIMESTAMP_RESET_FIRSTTIME_ONLY  = U32(0x00000000)
const TIMESTAMP_RESET_ALWAYS          = U32(0x00000001)

"""
DAC Names used by API AlazarDACSettingAdjust
"""
# DAC Names Specific to the ATS460
const ATS460_DAC_A_GAIN           = U32(0x00000001)
const ATS460_DAC_A_OFFSET         = U32(0x00000002)
const ATS460_DAC_A_POSITION       = U32(0x00000003)
const ATS460_DAC_B_GAIN           = U32(0x00000009)
const ATS460_DAC_B_OFFSET         = U32(0x0000000A)
const ATS460_DAC_B_POSITION       = U32(0x0000000B)
const ATS460_DAC_EXTERNAL_CLK_REF = U32(0x00000007)

# DAC Names Specific to the ATS660
const ATS660_DAC_A_GAIN           = U32(0x00000001)
const ATS660_DAC_A_OFFSET         = U32(0x00000002)
const ATS660_DAC_A_POSITION       = U32(0x00000003)
const ATS660_DAC_B_GAIN           = U32(0x00000009)
const ATS660_DAC_B_OFFSET         = U32(0x0000000A)
const ATS660_DAC_B_POSITION       = U32(0x0000000B)
const ATS660_DAC_EXTERNAL_CLK_REF = U32(0x00000007)

# DAC Names Specific to the ATS665
const ATS665_DAC_A_GAIN           = U32(0x00000001)
const ATS665_DAC_A_OFFSET         = U32(0x00000002)
const ATS665_DAC_A_POSITION       = U32(0x00000003)
const ATS665_DAC_B_GAIN           = U32(0x00000009)
const ATS665_DAC_B_OFFSET         = U32(0x0000000A)
const ATS665_DAC_B_POSITION       = U32(0x0000000B)
const ATS665_DAC_EXTERNAL_CLK_REF = U32(0x00000007)

# Error return values
const SETDAC_INVALID_SETGET	   =  660
const SETDAC_INVALID_CHANNEL   =  661
const SETDAC_INVALID_DACNAME   =  662
const SETDAC_INVALID_COUPLING  =  663
const SETDAC_INVALID_RANGE	   =  664
const SETDAC_INVALID_IMPEDANCE =  665
const SETDAC_BAD_GET_PTR       =  667
const SETDAC_INVALID_BOARDTYPE =  668

const CSO_DUMMY_CLOCK_DISABLE	           = 0
const CSO_DUMMY_CLOCK_TIMER		           = 1
const CSO_DUMMY_CLOCK_EXT_TRIGGER	       = 2
const CSO_DUMMY_CLOCK_TIMER_ON_TIMER_OFF = 3

"""
Auxiliary IO; this section had unsigned declaration in C API
"""
const AUX_OUT_TRIGGER               = U32(0)
const AUX_OUT_PACER                 = U32(2)
const AUX_OUT_BUSY                  = U32(4)
const AUX_OUT_CLOCK                 = U32(6)
const AUX_OUT_RESERVED              = U32(8)
const AUX_OUT_CAPTURE_ALMOST_DONE	= U32(10)
const AUX_OUT_AUXILIARY             = U32(12)
const AUX_OUT_SERIAL_DATA           = U32(14)
const AUX_OUT_TRIGGER_ENABLE        = U32(16)

const AUX_IN_TRIGGER_ENABLE         = U32(1)
const AUX_IN_DIGITAL_TRIGGER        = U32(3)
const AUX_IN_GATE					= U32(5)
const AUX_IN_CAPTURE_ON_DEMAND		= U32(7)
const AUX_IN_RESET_TIMESTAMP		= U32(9)
const AUX_IN_SLOW_EXTERNAL_CLOCK	= U32(11)
const AUX_IN_AUXILIARY				= U32(13)
const AUX_IN_SERIAL_DATA			= U32(15)

const AUX_INPUT_AUXILIARY			= AUX_IN_AUXILIARY
const AUX_INPUT_SERIAL_DATA			= AUX_IN_SERIAL_DATA

# AlazarSetExternalTriggerOperationForScanning
const STOS_OPTION_DEFER_START_CAPTURE	= U32(1)

# Data skipping
const SSM_DISABLE             =	U32(0)
const SSM_ENABLE              =	U32(1)

# Coprocessor
const CPF_REG_SIGNATURE       = U32(0)
const CPF_REG_REVISION        = U32(1)
const CPF_REG_VERSION         = U32(2)
const CPF_REG_STATUS          = U32(3)

const CPF_OPTION_DMA_DOWNLOAD = U32(1)

const CPF_DEVICE_UNKNOWN      = U32(0)
const CPF_DEVICE_EP3SL50      = U32(1)
const CPF_DEVICE_EP3SE260     = U32(2)

const LSB_DEFAULT             = U32(0)
const LSB_EXT_TRIG	          = U32(1)
const LSB_AUX_IN_0	          = U32(2)
const LSB_AUX_IN_1	          = U32(3)

"""
AutoDMA acquisitions flags
Control Flags for AutoDMA used in AlazarStartAutoDMA

Note: Not all AlazarTech devices are capable of dual-ported
acquisitions. Please see your board's specification for more
information.
"""
const ADMA_EXTERNAL_STARTCAPTURE  = U32(0x00000001)
const ADMA_ENABLE_RECORD_HEADERS  = U32(0x00000008)
const ADMA_SINGLE_DMA_CHANNEL     = U32(0x00000010)
const ADMA_ALLOC_BUFFERS          = U32(0x00000020)
const ADMA_TRADITIONAL_MODE       = U32(0x00000000)
const ADMA_CONTINUOUS_MODE        = U32(0x00000100)
const ADMA_NPT                    = U32(0x00000200)
const ADMA_TRIGGERED_STREAMING    = U32(0x00000400)
const ADMA_FIFO_ONLY_STREAMING    = U32(0x00000800)
const ADMA_INTERLEAVE_SAMPLES     = U32(0x00001000)
const ADMA_GET_PROCESSED_DATA     = U32(0x00002000)
const ADMA_ENABLE_RECORD_FOOTERS  = U32(0x00010000)

const ADMA_CLOCKSOURCE            = U32(0x00000001)
const ADMA_CLOCKEDGE              = U32(0x00000002)
const ADMA_SAMPLERATE             = U32(0x00000003)
const ADMA_INPUTRANGE             = U32(0x00000004)
const ADMA_INPUTCOUPLING          = U32(0x00000005)
const ADMA_IMPUTIMPEDENCE         = U32(0x00000006)       # typooo
const ADMA_EXTTRIGGERED           = U32(0x00000007)
const ADMA_CHA_TRIGGERED          = U32(0x00000008)
const ADMA_CHB_TRIGGERED          = U32(0x00000009)
const ADMA_TIMEOUT                = U32(0x0000000A)
const ADMA_THISCHANTRIGGERED      = U32(0x0000000B)
const ADMA_SERIALNUMBER           = U32(0x0000000C)
const ADMA_SYSTEMNUMBER           = U32(0x0000000D)
const ADMA_BOARDNUMBER            = U32(0x0000000E)
const ADMA_WHICHCHANNEL           = U32(0x0000000F)
const ADMA_SAMPLERESOLUTION       = U32(0x00000010)
const ADMA_DATAFORMAT             = U32(0x00000011)

"""Boards"""
const ATS850  = 1
const ATS310  = 2
const ATS330  = 3
const ATS855  = 4
const ATS315  = 5
const ATS335  = 6
const ATS460  = 7
const ATS860  = 8
const ATS660  = 9
const ATS665  = 10
const ATS9462 = 11
const ATS9434 = 12
const ATS9870 = 13
const ATS9350 = 14
const ATS9325 = 15
const ATS9440 = 16
const ATS9410 = 17
const ATS9351 = 18
const ATS9310 = 19
const ATS9461 = 20
const ATS9850 = 21
const ATS9625 = 22
const ATG6500 = 23
const ATS9626 = 24
const ATS9360 = 25
const AXI9870 = 26
const ATS9370 = 27
const ATU7825 = 28
const ATS9373 = 29
const ATS9416 = 30
#
# boardNames = {
#     ATS850 : "ATS850" ,
#     ATS310 : "ATS310" ,
#     ATS330 : "ATS330" ,
#     ATS855 : "ATS855" ,
#     ATS315 : "ATS315" ,
#     ATS335 : "ATS335" ,
#     ATS460 : "ATS460" ,
#     ATS860 : "ATS860" ,
#     ATS660 : "ATS660" ,
#     ATS665 : "ATS665" ,
#     ATS9462: "ATS9462",
#     ATS9434: "ATS9434",
#     ATS9870: "ATS9870",
#     ATS9350: "ATS9350",
#     ATS9325: "ATS9325",
#     ATS9440: "ATS9440",
#     ATS9410: "ATS9410",
#     ATS9351: "ATS9351",
#     ATS9310: "ATS9310",
#     ATS9461: "ATS9461",
#     ATS9850: "ATS9850",
#     ATS9625: "ATS9625",
#     ATG6500: "ATG6500",
#     ATS9626: "ATS9626",
#     ATS9360: "ATS9360",
#     AXI9870: "AXI9870",
#     ATS9370: "ATS9370",
#     ATU7825: "ATU7825",
#     ATS9373: "ATS9373",
#     ATS9416: "ATS9416"
# };
#
"""Record average options"""
const CRA_MODE_DISABLE         = U32(0)
const CRA_MODE_ENABLE_FPGA_AVE = U32(1)
const CRA_OPTION_UNSIGNED      = U32(0)
const CRA_OPTION_SIGNED        = U32(1)
