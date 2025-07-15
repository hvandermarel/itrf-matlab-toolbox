%% Plot map of ITRF and ETRF velocity or coordinate changes
%
% Script to plot ITRF and ETRF velocity and position differences, with
% or without plate motion model correction.
%
% Created:  9 February 2018 by Hans van der Marel
% Modified: 2 june 2025 by Hans van der Marel
%            - Major overhaul using itrf toolbox version 2 (with newly
%              added pmm functions and support for more TRF's)
%            - optional correction for plate motion (pmm)
%            - choice between plotting velocity differences and position
%              differences
%            - added option for low-resolution maps (useful when high
%              resolution shape files are unavailable)

%% Add required toolboxes to the Matlab path
%
% Requires the Matlab mapping toolbox (if not available, should not be
% too difficult to adjust the plotting part using coastlines only). 

addtoolbox('itrf');
addtoolbox('crsutil');    % import plh2xyz and xyz2neu from crsutil

% addpath('d:\Surfdrive\Matlab\toolbox\itrf')
% addpath('d:\Surfdrive\Matlab\toolbox\crsutil')

%% Legend to itrfvelmap arguments
% 
% Reference frames          Plate motion model (none/pmm) -----+
%   from ------------+                                         |
%   to ------+       |             Plot type (vel/pos) --+     |
%            |       |                                   |     |
%            v       v                                   v     v
% itrfmap(refto, reffrom, refepoch, latrange, lonrange, sel,  pmm, tecplate, id)

%% Velocity and position differences over Europe

% ROI and map limits for Europe

latrange=[35 68]; lonrange=[-12 35 ];     

% Examples of itrfvelmap (uncomment one or more)

% itrfmap('ITRF2008', 'ETRF2000', 2010.0, latrange, lonrange)
% itrfmap('ITRF2014', 'ETRF2000', 2018.0, latrange, lonrange, 'vel')
% itrfmap('ITRF2020', 'ETRF2000', 2020.0, latrange, lonrange, 'vel', 'none')
itrfmap('ITRF2008', 'ETRF2000', 2020.0, latrange, lonrange, 'vel', 'GSRM 2.1 IGS08', 'Eurasia')
%
% itrfmap('ITRF2020', 'ITRF2014', 2020.0, latrange, lonrange, 'vel', 'none')
%
% itrfmap('ITRF2008', 'ETRF2020', 1989.0, latrange, lonrange, 'pos', 'none')
% itrfmap('ITRF2008', 'ETRF2020', 2020.0, latrange, lonrange, 'pos', 'GSRM 2.1 IGS08', 'Eurasia')
% itrfmap('ITRF2020', 'ETRF2020', 1989.0, latrange, lonrange, 'pos', 'none')
% itrfmap('ITRF2020', 'ETRF2020', 2020.0, latrange, lonrange, 'pos', 'ITRF2020', 'Eurasia')


%% Velocity and position differences over the Netherlands

% Add optional folder with high-resolution land areas, rivers and borders 
% to Matlab path, if not available, low resolution maps that come with the
% Matlab mapping toolbox are used.

addpath('d:\Surfdrive\Matlab\models\')

% ROI and map limits for the Netherlands

latrange=[50 54.5];
lonrange=[1.5 8.5 ];

% Examples of itrfvelmap (uncomment one or more)

itrfmap('ITRF2008', 'ETRF2000', 2020, latrange, lonrange, 'vel', 'GSRM 2.1 IGS08', 'Eurasia','nweurope')
% itrfmap('ETRF2020', 'ETRF2014', 2020, latrange, lonrange, 'vel', 'none', 'none', 'nweurope')

