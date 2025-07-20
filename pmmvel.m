function vel=pmmvel(pmm,tecplate,plh,varargin)
%PMMVEL   Get velocity from Plate Motion Model parameters.
%   VEL=PMMVEL(PMM,TECPLATE,PLH) returns a matrix with the North and
%   East plate velocity in m/y for stations on tectonic plate TECPLATE
%   with Latitude, Longitude and Height PLH in rad and meters using 
%   Plate Motion Model PMM.
%
%   Currently supported plate motion models are "NUVEL 1A NNR", "ITRF2000", 
%   "ITRF2008", "ITRF2014", "ITRF2020", "GSRM 2.1 IGS08" and "GSRM 2.1 NNR". 
%   The tectonic plate can be specific by it's full name, a 2-letter 
%   (available for all plates) or 4-letter abbreviation (available for some 
%   plates).  
%
%   VEL=PMMVEL(PMM,TECPLATE,PLH,'option',value,...) uses options 
%  
%      'APPLYORB'  boolean   apply the origin rotation bias (default true)
%      'SPHERICAL' boolean   use spherical coordinates instead of geodetic
%                            in internal computation (default false)
%      'ZEROVERT'  boolean   set vertical velocity to zero (default true)
%
%   Examples:
%
%      vel = pmmvel('GSRM 2.1 NNR','EU',plh);
%      vel = pmmvel('ITRF2020','EURA',plh);
%      vel = pmmvel('ITRF2020','Eurasia',plh,'APPLYORB',false);
%      vel = pmmvel('ITRF2020','EURA',plh,'APPLYORB',false,'ZEROVERT',false);
%
%   See also PMMPAR.
%
%   (c) Hans van der Marel, Delft University of Technology, 2025.

% GRS80 ellipsoid 

a=6378137.;
f=1/298.257222101; 
Re=6371000;

% Process options

opt.applyorb=true;
opt.zerovert=true;
opt.spherical=false;
for k=1:2:numel(varargin)
    if isfield(opt,lower(varargin{k}))
       opt.(lower(varargin{k}))=varargin{k+1};
    else
       warning(['Invalid option ' varargin{k} ', ignore and continue...'])
    end
end

% Get the plate rotation vector and origin rotation bias

[omega_xyz,orb]=pmmpar(pmm,tecplate);
if ~opt.applyorb
   orb = [0 0 0];
end

% Compute Cartesian coordinates 

n= [ cos(plh(:,1)).*cos(plh(:,2)) cos(plh(:,1)).*sin(plh(:,2))  sin(plh(:,1)) ];
if opt.spherical
    xyz = Re.*n;
else
    e2 = 2*f - f^2;
    N = a ./ sqrt(1 - e2 .* sin(plh(:,1)).^2);
    xyz = [ (N+plh(:,3)).*n(:,1) ...
            (N+plh(:,3)).*n(:,2) ...
            (N-e2.*N+plh(:,3)).*n(:,3) ];
end

% Compute the velocity vector

pdot=omega_xyz*1e-6*pi/180;  % deg/My - > rad/y
Rdot=[ 0 -pdot(3) pdot(2) ; pdot(3) 0 -pdot(1) ; -pdot(2) pdot(1) 0];
velxyz = xyz*Rdot' + repmat(orb/1000, [size(xyz,1) 1]);

% Convert velocity vector into North, East and Up components 

% neu = [ ( -n(:,1).*xyz(:,1) - n(:,2).*xyz(:,2) ) .* n(:,3) ./ cphi + cphi.*xyz(:,3)     ...
%         ( -n(:,2).*xyz(:,1) + n(:,1).*xyz(:,2) ) ./  cphi                              ...
%            n(:,1).*xyz(:,1) + n(:,2).*xyz(:,2) + n(:,3).*xyz(:,3) ]

cphi= sqrt(1-n(:,3).^2);
ip=n(:,1).*velxyz(:,1) + n(:,2).*velxyz(:,2) + n(:,3).*velxyz(:,3);
vel = [ (  ip .* -n(:,3)  + velxyz(:,3) ) ./ cphi               ...
        ( -n(:,2).*velxyz(:,1) + n(:,1).*velxyz(:,2) ) ./  cphi    ...
           ip                                                  ];

if opt.zerovert
   vel(:,3) = zeros(size(vel,1),1);
end

end
