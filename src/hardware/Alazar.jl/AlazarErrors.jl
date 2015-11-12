import PainterQB: InstrumentException

const noError = 512
exceptions = [
    "ApiNoError",                             # 512
    "ApiFailed",                              # 513
    "ApiAccessDenied",                        # 514
    "ApiDmaChannelUnavailable",               # 515
    "ApiDmaChannelInvalid",                   # 516
    "ApiDmaChannelTypeError",                 # 517
    "ApiDmaInProgress",                       # 518
    "ApiDmaDone",                             # 519
    "ApiDmaPaused",                           # 520
    "ApiDmaNotPaused",                        # 521
    "ApiDmaCommandInvalid",                   # 522
    "ApiDmaManReady",                         # 523
    "ApiDmaManNotReady",                      # 524
    "ApiDmaInvalidChannelPriority",           # 525
    "ApiDmaManCorrupted",                     # 526
    "ApiDmaInvalidElementIndex",              # 527
    "ApiDmaNoMoreElements",                   # 528
    "ApiDmaSglInvalid",                       # 529
    "ApiDmaSglQueueFull",                     # 530
    "ApiNullParam",                           # 531
    "ApiInvalidBusIndex",                     # 532
    "ApiUnsupportedFunction",                 # 533
    "ApiInvalidPciSpace",                     # 534
    "ApiInvalidIopSpace",                     # 535
    "ApiInvalidSize",                         # 536
    "ApiInvalidAddress",                      # 537
    "ApiInvalidAccessType",                   # 538
    "ApiInvalidIndex",                        # 539
    "ApiMuNotReady",                          # 540
    "ApiMuFifoEmpty",                         # 541
    "ApiMuFifoFull",                          # 542
    "ApiInvalidRegister",                     # 543
    "ApiDoorbellClearFailed",                 # 544
    "ApiInvalidUserPin",                      # 545
    "ApiInvalidUserState",                    # 546
    "ApiEepromNotPresent",                    # 547
    "ApiEepromTypeNotSupported",              # 548
    "ApiEepromBlank",                         # 549
    "ApiConfigAccessFailed",                  # 550
    "ApiInvalidDeviceInfo",                   # 551
    "ApiNoActiveDriver",                      # 552
    "ApiInsufficientResources",               # 553
    "ApiObjectAlreadyAllocated",              # 554
    "ApiAlreadyInitialized",                  # 555
    "ApiNotInitialized",                      # 556
    "ApiBadConfigRegEndianMode",              # 557
    "ApiInvalidPowerState",                   # 558
    "ApiPowerDown",                           # 559
    "ApiFlybyNotSupported",                   # 560
    "ApiNotSupportThisChannel",               # 561
    "ApiNoAction",                            # 562
    "ApiHSNotSupported",                      # 563
    "ApiVPDNotSupported",                     # 564
    "ApiVpdNotEnabled",                       # 565
    "ApiNoMoreCap",                           # 566
    "ApiInvalidOffset",                       # 567
    "ApiBadPinDirection",                     # 568
    "ApiPciTimeout",                          # 569
    "ApiDmaChannelClosed",                    # 570
    "ApiDmaChannelError",                     # 571
    "ApiInvalidHandle",                       # 572
    "ApiBufferNotReady",                      # 573
    "ApiInvalidData",                         # 574
    "ApiDoNothing",                           # 575
    "ApiDmaSglBuildFailed",                   # 576
    "ApiPMNotSupported",                      # 577
    "ApiInvalidDriverVersion",                # 578
    "ApiWaitTimeout",                         # 579
    "ApiWaitCanceled",                        # 580
    "ApiBufferTooSmall",                      # 581
    "ApiBufferOverflow",                      # 582
    "ApiInvalidBuffer",                       # 583
    "ApiInvalidRecordsPerBuffer",             # 584
    "ApiDmaPending",                          # 585
    "ApiLockAndProbePagesFailed",             # 586
    "ApiWaitAbandoned",                       # 587
    "ApiWaitFailed",                          # 588
    "ApiTransferComplete",                    # 589
    "ApiPllNotLocked",                        # 590
    "ApiNotSupportedInDualChannelMode",       # 591
    "ApiNotSupportedInQuadChannelMode",       # 592
    "ApiFileIoError",                         # 593
    "ApiInvalidClockFrequency",               # 594
    "ApiInvalidSkipTable",                    # 595
    "ApiInvalidDspModule",                    # 596
    "ApiDESOnlySupportedInSingleChannelMode", # 597
    "ApiInconsistentChannel",                 # 598
    "ApiLastError"                            # Do not add API errors below this line
]

"Create descriptive exceptions."
InstrumentException(ins::InstrumentAlazar, r) = InstrumentException(ins, r, exceptions[r-511])

# export @eh
#
# "Error intercept macro."
# macro eh(expr)
#     quote
#         local r = $(esc(expr))
#         if (r != noError)
#             throw(InstrumentException($(esc(expr.args[2])),r))
#         end
#         r
#     end
# end

"Error intercept macro. Takes a function definition and brackets the RHS with some checking."
macro eh(expr)
    quote
        $(esc(expr.args[1])) = begin
            r = $(esc(expr.args[2]))
            if (r != noError)
                throw(InstrumentException($(esc(expr.args[1].args[2].args[1])),r))
            end
            r
        end
    end
end
