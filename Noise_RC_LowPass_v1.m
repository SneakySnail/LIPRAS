% Constants
R = 5E8*(1e-6)/(0.5*pi*(45E-6)^2); % Resistance in ohms (parallel)
C = 8.85E-12*16*(0.5*pi*(45E-6)^2)/(1e-6); % Capacitance in farads
k = 1.38e-23; % Boltzmann's constant
T = 1073; % Temperature in kelvin

% Frequency range
f = logspace(2, 6, 1000); % Frequency in Hz from 1 to 100,000
% f=999:1001;
% Complex frequency variable
s = 1i * 2 * pi * f;

% Transfer function
H_f =1./(s*C) ./ (R + 1./(s*C));
% Squared magnitude of the transfer function
H_f_squared = abs(H_f).^2;

% Noise power spectral density (considering resistor)
S_n = 4 * k * T * R * H_f_squared;

Vn=sqrt(trapz(f,S_n));

Z=1./(1i*2*pi*f*C);
S_n1 = 4*k*T*R.*abs(Z./(R+Z)).^2;

% Plot
close
loglog(f, S_n);
hold("on")
loglog(f, S_n1);
hold off

xlabel('Frequency (Hz)');
ylabel('Noise Power Spectral Density (V^2/Hz)');
title('Noise Power Spectral Density for a High-Pass RC Filter');
grid on;
