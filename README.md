![stack Overflow](https://github.com/SneakySnail/LIPRAS/blob/master/Logo/Logo_R3.png?raw=true)
# Line-Profile Analysis Software (LIPRAS)


##Authors
Giovanni Esteves, Klarissa Ramos, Chris Fancher, and Jacob Jones

## What is LIPRAS?

**LIPRAS** [*LEEP-ruhs*], short for **Line-Profile Analysis Software**, is a graphical user interface for least-squares fitting of Bragg peaks in powder diffraction data. For any region of the inputted data, user can choose which profile functions to apply to the fit, constrain profile functions, and view the resulting fit in terms of the profile functions chosen. 


## Why should I use it?
You can use LIPRAS to visualize and analyze diffraction data. 

Authors: Giovanni Esteves, Klarissa Ramos, Chris Fancher, and Jacob Jones
<ol>
• Quickly extract relevant peak information about the **position**, **full width at half maximum (FWHM)**, and **intensity**
• Customize the background fit by either treating it separately (Polynomial or Spline) or including it in the least-square routine (Polynomial only)
• Fit up to **20 peaks** in the current profile region 
• Choose from 5 different peak-shape functions: **Gaussian, Lorentzian, Pseudo-Voigt, and Pearson VII**, with an additional modified function **Asymmetric Pearson VII** 
• Peak-shape functions can be constrained in terms of intensity, peak position, FWHM, and mixing coefficient
• Automatically calculate **Cu-Kalpha2** peaks when working with laboratory X-ray data 
• Change any of the starting fit values and instantly view a sample plot of the fit, before conducting a fit
• For multiple diffraction patterns, results from previous fit are subsequent starting parameters for next fit 
• Visualize results with a plot of the resulting peak fit and residual plot
• Resulting coefficients values can be viewed with file number 
• Parameters files can be written and used to recreate fits and detail what fit parameters and profile shape functions were used
• Accepts the following **file types: .xy, .xls, .xlsx, .fxye, .xrdml, .chi, .csv (Windows Only)**
</ol>

## Installation
**MATLAB Users**
**Requires MATLAB 2016b and GUI Layout Toolbox to run**

You can start using LIPRAS in MATLAB after downloading GUI Layout Toolbox with a **MATLAB version 2016b or greater**. 

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
