function acquireData(a::AlazarATS9360)

    # Calculate the number of buffers in the acquisition
    bytesPerSample = Alazar.bytesPerSample(a)           # Going to be 1 or 2, always 2 for ATS9360
    samplesPerBuffer = Alazar.samplesPerBuffer(a)       # Fixed in method definition
    bytesPerBuffer = Alazar.bytesPerBuffer(a)                   # bytesPerSample * samplesPerBuffer * channelCount
    samplesPerAcquisition = Alazar.samplesPerAcquisition(a)
    buffersPerAcquisition = U32(floor((samplesPerAcquisition + samplesPerBuffer - 1) / samplesPerBuffer))   # check this

    # Allocate memory for DMA buffers
    bufferCount = Alazar.bufferCount(a)                 # Fixed in method definition
    bufferArray = Array{DMABuffer{UInt16},1}()

    for (bufferIndex = 1:BUFFER_COUNT)
        push!(bufferArray,DMABuffer(bytesPerSample,bytesPerBuffer))
    end

    admaFlags = U32(Alazar.ADMA_EXTERNAL_STARTCAPTURE | Alazar.ADMA_CONTINUOUS_MODE | Alazar.ADMA_FIFO_ONLY_STREAMING)
    beforeAsyncRead( a, a.acquisitionChannel,
                        0, # Must be 0
                        samplesPerBuffer,
                        1,          # Must be 1
                        0x7FFFFFFF, # Ignored. Behave as if infinite
                        admaFlags)

    # Add the buffers to a list of buffers available to be filled by the board
    for (bufferIndex = 1:BUFFER_COUNT)
        pBuffer = bufferArray[bufferIndex].addr
        postAsyncBuffer(a, pBuffer, bytesPerBuffer)
    end

    # Arm the board system to wait for a trigger event to begin the acquisition
    startCapture(a)
    println("Capturing $buffersPerAcquisition buffers ...")

    buffersCompleted = 0
    bytesTransferred = 0
    timeout_ms = 5000

    try
        startTickCount = time()
        while (buffersCompleted < buffersPerAcquisition)

            # TODO: Set a buffer timeout that is longer than the time
            #       required to capture all the records in one buffer.

            # Wait for the buffer at the head of the list of available buffers
            # to be filled by the board.
            bufferIndex = mod(buffersCompleted, BUFFER_COUNT)
            pBuffer = bufferArray[bufferIndex+1].addr
            waitAsyncBufferComplete(a, pBuffer, timeout_ms)

            buffersCompleted += 1
            bytesTransferred += bytesPerBuffer;

            # TODO: Process sample data in this buffer.

            # NOTE:
            #
            # While you are processing this buffer, the board is already filling the next
            # available buffer(s).
            #
            # You MUST finish processing this buffer and post it back to the board before
            # the board fills all of its available DMA buffers and on-board memory.
            #
            # Samples are arranged in the buffer as follows: S0A, S0B, ..., S1A, S1B, ...
            # with SXY the sample number X of channel Y.
            #
            # A 12-bit sample code is stored in the most significant bits of in each 16-bit
            # sample value.
            # Sample codes are unsigned by default. As a result:
            # - a sample code of 0x0000 represents a negative full scale input signal.
            # - a sample code of 0x8000 represents a ~0V signal.
            # - a sample code of 0xFFFF represents a positive full scale input signal.

            # Add the buffer to the end of the list of available buffers.
            postAsyncBuffer(a, pBuffer, bytesPerBuffer)
        end

        # Display results
        transferTime_sec = (time() - startTickCount)
        println("Capture completed in $transferTime_sec s.")

        if (transferTime_sec > 0.)
            buffersPerSec = buffersCompleted / transferTime_sec
            bytesPerSec = bytesTransferred / transferTime_sec
        else
            buffersPerSec = 0.
            bytesPerSec = 0.
        end

        println("Captured $buffersCompleted buffers ($buffersPerSec buffers / s)")
        println("Transferred $bytesTransferred bytes ($bytesPerSec bytes / s)")
    finally
        abortAsyncRead(a)
    end

end
