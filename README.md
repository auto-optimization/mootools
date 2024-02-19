MOOCORE: Core Mathematical Functions for Multi-Objective Optimization
==============================================
<!-- badges: start -->
[![C build
status](https://github.com/auto-optimization/mootools/workflows/C/badge.svg)](https://github.com/auto-optimization/mootools/actions/workflows/C.yaml)
[![Python build
status](https://github.com/auto-optimization/mootools/workflows/Python/badge.svg)](https://github.com/auto-optimization/mootools/actions/workflows/python.yaml)
[![R build
status](https://github.com/auto-optimization/mootools/workflows/R/badge.svg)](https://github.com/auto-optimization/mootools/actions/workflows/R.yaml)
<!-- badges: end -->

[ [**GitHub**](https://auto-optimization.github.io/mootools) ] [ [**R package**](https://auto-optimization.github.io/mootools/r/) ] [ [**Python package**](https://auto-optimization.github.io/mootools/python/) ]

**Contributors:**
    [Manuel López-Ibáñez](https://lopez-ibanez.eu),


The goal of this repository is to collect core mathematical functions and algorithms for multi-objective optimization and make them available to different programming languages via similar interfaces. These functions include:

 * Identifying and filtering dominated vectors.
 * Quality metrics such as (weighted) hypervolume, epsilon, IGD, etc.
 * Computation of the Empirical Attainment Function.
 
The repository is composed of:

 * `src/`: C library and command-line tools.
 * `r/`: An R package that uses the C library.
 * `python/`: A Python package that uses the C library.
 
Each component is documented in the `README.md` file found under each folder.

