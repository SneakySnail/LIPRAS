![stack Overflow](https://github.com/SneakySnail/LIPRAS/blob/master/Logo/Logo_R3.png?raw=true)
# Line-Profile Analysis Software (LIPRAS)


## Authors
Giovanni Esteves, Klarissa Ramos, Chris Fancher, and Jacob Jones

<b> Histroy: </b>The backbone of the code was originally created by Jacob Jones during his post doc years in MATLAB back in 2007. In 2014, Chris Fancher continued development of the code created by Jacob and successfully turned it into a class structure within MATLAB. Giovanni further builded upon Chris's version by polishing the code and adding features to enhances its feasability to new users. Finally, in 2016 Klarissa joined the Jones Research group and jointly with Giovanni they restructured the class structure file into a graphical user interface (GUI) which is now known as LIPRAS.

## What is LIPRAS?

**LIPRAS** [*LEEP-ruhs*], short for **Line-Profile Analysis Software**, is a graphical user interface for least-squares fitting of Bragg peaks in powder diffraction data. For any region of the inputted data, user can choose which profile functions to apply to the fit, constrain profile functions, and view the resulting fit in terms of the profile functions chosen. 


## Features in LIPRAS
<b> Why use LIPRAS?</b> You can use LIPRAS to visualize and analyze diffraction data.

<li> Quickly extract relevant peak information about the <b>position, full width at half maximum (FWHM), and intensity</b> </li>
<li> Customize the background fit by either treating it separately (Polynomial or Spline) or including it in the least-square routine (Polynomial only)</li>
<li> Fit up to <b>20 peaks</b> in the current profile region </li>
<li> Choose from 5 different peak-shape functions: <b>Gaussian, Lorentzian, Pseudo-Voigt, and Pearson VII, and Asymmetric Pearson VII</b> </li>
<li> Peak-shape functions can be constrained in terms of intensity, peak position, FWHM, and mixing coefficient</li>
<li> Automatically calculate **Cu-Kalpha2** peaks when working with laboratory X-ray data </li>
<li> Change any of the starting fit values and instantly view a sample plot of the fit, before conducting a fit</li>
<li> For multiple diffraction patterns, results from previous fit are subsequent starting parameters for next fit </li>
<li> Visualize results with a plot of the resulting peak fit and residual plot</li>
<li> Resulting coefficients values can be viewed with file number </li>
<li> Parameters files can be written and used to recreate fits and detail what fit parameters and profile shape functions were used</li>
<li> Accepts the following <b>file types: .xy, .xls, .xlsx, .fxye, .xrdml, .chi, .csv (Windows Only)</b></li>


## Installation
**MATLAB Users**

**Requires MATLAB 2016b and GUI Layout Toolbox to run**

You can start using LIPRAS in MATLAB after downloading GUI Layout Toolbox with a MATLAB version 2016b or greater. 

GUI Layout Toolbox: https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox

## License
LIPRAS BSD License,
Copyright (c) 2017, North Carolina State University
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided
that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the
following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
the following disclaimer in the documentation and/or other materials provided with the distribution.
3. The names “North Carolina State University”, “NCSU” and any trade‐name, personal name,
trademark, trade device, service mark, symbol, image, icon, or any abbreviation, contraction or
simulation thereof owned by North Carolina State University must not be used to endorse or promote
products derived from this software without prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
