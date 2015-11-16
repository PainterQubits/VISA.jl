# VISA wrapper for Julia

Bare-bones Julia wrapper for VISA libraries, using C calls. Tested with the NI-VISA library.

Pulled out of [BBN-Q/Instruments.jl](https://github.com/BBN-Q/Instruments.jl) into a self-contained module.

## Installation

[Download and install the NI-VISA libraries.](https://www.ni.com/visa/)

Pkg.clone("https://github.com/ajkeller34/VISA.jl.git")
Pkg.build("VISA")
