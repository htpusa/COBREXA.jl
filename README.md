<br>
<div align="center">
    <img src="docs/src/assets/header.svg?maxAge=0" width="80%">
</div>

# COnstraint-Based Reconstruction and EXascale Analysis

[docs-img]:https://img.shields.io/badge/docs-latest-blue.svg
[docs-url]: http://lcsb-biocore.github.io/COBREXA.jl

[ci-img]: https://github.com/LCSB-BioCore/COBREXA.jl/actions/workflows/ci.yml/badge.svg?branch=master
[ci-url]: https://github.com/LCSB-BioCore/COBREXA.jl/actions/workflows/ci.yml

[cov-img]: https://codecov.io/gh/LCSB-BioCore/COBREXA.jl/branch/master/graph/badge.svg?token=H3WSWOBD7L
[cov-url]: https://codecov.io/gh/LCSB-BioCore/COBREXA.jl

[contrib-img]: https://img.shields.io/badge/contributions-start%20here-green
[contrib-url]: https://github.com/LCSB-BioCore/COBREXA.jl/blob/master/.github/CONTRIBUTING.md

| **Documentation** | **Tests** | **Coverage** | **How to contribute?** |
|:--------------:|:-------:|:---------:|:---------:|
| [![docs-img]][docs-url] | [![CI][ci-img]][ci-url] | [![codecov][cov-img]][cov-url] | [![contrib][contrib-img]][contrib-url] |

This is package provides constraint-based reconstruction and analysis tools for
exa-scale metabolic models in Julia.

## How to get started

### Prerequisites and requirements

- **Operating system**: Use Linux (Debian, Ubuntu or centOS), MacOS, or Windows
  10 as your operating system. `COBREXA` has been tested on these systems.
- **Julia language**: In order to use `COBREXA`, you need to install Julia 1.0
  or higher. Download and follow the installation instructions for Julia
  [here](https://julialang.org/downloads/).
- **Hardware requirements**: `COBREXA` runs on any hardware that can run Julia,
  and can easily use resources from multiple computers interconnected on a
  network. For processing large datasets, you are required to ensure that the
  total amount of available RAM on all involved computers is larger than the
  data size.
- **Optimization solvers**: `COBREXA` uses
  [`JuMP.jl`](https://github.com/jump-dev/JuMP.jl) to formulate optimization
  problems and is compatible with all [`JuMP` supported
  solvers](https://jump.dev/JuMP.jl/stable/installation/#Supported-solvers).
  However, to perform analysis at least one of these solvers needs to be
  installed on your machine. For a pure Julia implementation, you may use e.g.
  [`Tulip.jl`](https://github.com/ds4dm/Tulip.jl), but other solvers (GLPK,
  Gurobi, ...) work just as well.

:bulb: If you are new to Julia, it is advisable to [familiarize yourself with
the environment
first](https://docs.julialang.org/en/v1/manual/getting-started/).  Use the
Julia [documentation](https://docs.julialang.org) to solve various
language-related issues, and the [Julia package manager
docs](https://julialang.github.io/Pkg.jl/v1/getting-started/) to solve
installation-related difficulties. Of course, [the Julia
channel](https://discourse.julialang.org/) is another fast and easy way to find
answers to Julia specific questions.

### Quick start guide

<!--quickstart_begin-->
You can install COBREXA from Julia repositories. Start `julia`, **press `]`** to
switch to the Packaging environment, and type:
```
add COBREXA
```

You also need to install your favorite solver supported by `JuMP.jl`, typing
e.g.:
```
add Tulip
```

When the packages are installed, switch back to the "normal" julia shell by
pressing Backspace (the prompt should change color back to green). After that,
you can download [a SBML model from the
internet](http://bigg.ucsd.edu/models/e_coli_core) and perform a
flux balance analysis as follows:

```julia
using COBREXA   # loads the package
using Tulip     # loads the optimization solver

# download the model
download("http://bigg.ucsd.edu/static/models/e_coli_core.xml", "e_coli_core.xml")

# open the SBML file and load the contents
model = load_model("e_coli_core.xml")

# run a FBA
fluxes = flux_balance_analysis_dict(model, Tulip.Optimizer)
```

The variable `fluxes` will now contain a dictionary of the computed optimal
flux of each reaction in the model:
```
Dict{String,Float64} with 95 entries:
  "R_EX_fum_e"    => 0.0
  "R_ACONTb"      => 6.00725
  "R_TPI"         => 7.47738
  "R_SUCOAS"      => -5.06438
  "R_GLNS"        => 0.223462
  "R_EX_pi_e"     => -3.2149
  "R_PPC"         => 2.50431
  "R_O2t"         => 21.7995
  "R_G6PDH2r"     => 4.95999
  "R_TALA"        => 1.49698
  ⋮               => ⋮
```
<!--quickstart_end-->

### Testing the installation

If you run a non-standard platform (e.g. a customized operating system), or if
you added any modifications to the `COBREXA` source code, you may want to run
the test suite to ensure that everything works as expected:

```julia
] test COBREXA
```

<!--acknowledgements_begin-->
## Acknowledgements

`COBREXA.jl` is developed at the Luxembourg Centre for Systems Biomedicine of
the University of Luxembourg ([uni.lu/lcsb](https://www.uni.lu/lcsb)),
cooperating with the Institute for Quantitative and Theoretical Biology at the Heinrich
Heine University in Düsseldorf ([qtb.hhu.de](https://www.qtb.hhu.de/)).

The development was supported by European Union's Horizon 2020 Programme under
PerMedCoE project ([permedcoe.eu](https://www.permedcoe.eu/)) agreement no. 951773.
<!--acknowledgements_end-->

<!--ack_logos_begin-->
<img src="https://lcsb-biocore.github.io/COBREXA.jl/stable/assets/cobrexa.svg" alt="COBREXA logo" height="64px" style="height:64px; width:auto">   <img src="https://lcsb-biocore.github.io/COBREXA.jl/stable/assets/unilu.svg" alt="Uni.lu logo" height="64px" style="height:64px; width:auto">   <img src="https://lcsb-biocore.github.io/COBREXA.jl/stable/assets/lcsb.svg" alt="LCSB logo" height="64px" style="height:64px; width:auto">   <img src="https://lcsb-biocore.github.io/COBREXA.jl/stable/assets/hhu.svg" alt="HHU logo" height="64px" style="height:64px; width:auto">   <img src="https://lcsb-biocore.github.io/COBREXA.jl/stable/assets/qtb.svg" alt="QTB logo" height="64px" style="height:64px; width:auto">   <img src="https://lcsb-biocore.github.io/COBREXA.jl/stable/assets/permedcoe.svg" alt="PerMedCoE logo" height="64px" style="height:64px; width:auto">
<!--ack_logos_end-->

