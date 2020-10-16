
---
title: 'Line-Profile Analysis Software (LIPRAS)'
tags:
  - MATLAB
  - X-ray diffraction
  - Peak fitting
  
authors:
  - name: Giovanni Esteves, Klarissa Ramos, Chris M. Fancher, and Jacob L. Jones
    affiliation: 1
affiliations:
 - name: Department of Materials Science and Engineering, North Carolina State University, Raleigh, NC
   index: 1
date: 15 October 2020
bibliography: paper.bib
---

# Summary


Line-Profile Analysis is a common approach to quantify changes in diffraction data. Peaks can be modeled by profile shape functions (Gaussian, Lorentzian, Pearson VII, or Pseudo-Voigt) to extract peak position, full width at half maximum (FWHM), and intensity. Line-profile analysis can be applied to diffraction data from _in situ_ measurements during application of temperature, pressure, stress, and electric fields to detect and characterize subtle and significant changes. Additionally, line-profile analysis is particularly useful when the profile shapes or the combination of peaks cannot be adequately modeled in a full profile refinement such as that employed in Rietveld refinements.

LIPRAS, short for Line-Profile Analysis Software, is a graphical user interface for least squares peak fitting of Bragg peaks in diffraction data from both X-ray and neutron sources. For any region of the inputted data, the user can choose which profile functions to apply to the fit, constrain profile functions, and view the resulting fit in terms of the profile functions chosen. LIPRAS was designed to allow for customizability of the profile shape functions applied to diffraction data and for when simplicity and/or automation is needed. LIPRAS is equipped with five profile functions to conduct peak fit analysis: Gaussian, Lorentzian, Pearson-VII, pseudo-Voigt, and Split Pearson-VII (asymmetric). These profile functions can be added together (up to 20) and constrained by various profile coefficients to increase the number of possible models that can be used. The background can be modeled using a spline function or polynomial and can be treated separately or included in the least-squares routine. Profile coefficients and fit data are saved for all data files contained within the analysis.

A Bayesian inference analysis can be carried out on the resulting least squares results to generate a full description of the errors for all profile parameters. The algorithm used is a Markov Chain Monte Carlo (MCMC) Metropolis-in-Gibbs, which is described in Ref [1]. LIPRAS allows the user to have control of the parameter mean and standard deviation used in the algorithm to sample. Histograms of every parameter will be displayed at the end of the Bayesian analysis with the results saved accordingly at the end of each analysis. Description of the model used in LIPRAS is detailed in LIPRAS manual, provided in every download.

LIPRAS is open source and is written in MATLAB with a standalone version available. MATLAB users need to have the Curve Fitting Toolbox<sup>TM</sup> installed to do peak fitting using least squares and the Statistics and Machine Learning Toolbox<sup>TM</sup> for the Bayesian component of LIPRAS.

# Acknowledgements

This website is based in part upon work supported by the National Science Foundation under Grant No. 1409399. Any opinions, findings and conclusions or recommendations expressed in this website are those of the author(s) and do not necessarily reflect the views of the National Science Foundation (NSF).

# References

1. T. Iamsasri, J. Guerrier, G. Esteves, C. M. Fancher, A. G. Wilson, R. C. Smith, E. A. Paisley, R. Johnson-Wilke, J. F. Ihlefeld, N. Bassiri-Gharb, and J. L. Jones: A Bayesian approach to modeling diffraction profiles and application to ferroelectric materials. _J. Appl. Crystallogr._ **50**(1), 1 (2017).
