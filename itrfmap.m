function itrfmap(refto, reffrom, refepoch, latrange, lonrange, sel, pmm, tecplate,id)
%ITRFMAP  Plot map of ITRF/ETRF velocity and coordinate changes. 
%   ITRFMAP(REFTO,REFFROM,EPOCH,LATRANGE,LONGRANGE) plots the difference
%   in velocity for the reference frame REFTO with the velocity in REFFROM
%   on a map with latitude range LATRANGE and longitude range LONRANGE.
%   EPOCH is the epoch, but this is only used internally for the computation
%   and has no significance for the velocity output. 
%
%   ITRFMAP(...,SEL), with SEL='pos', plots the coordinate differences
%   instead of the velocity differences (SEL='vel' is the default). EPOCH
%   is the epoch for the coordinate difference. 
%
%   ITRFMAP(...,SEL,PMM,TECPLATE) applies a correction to REFTO using
%   the plate motion model given by PMM for tectonic plates TECPLATE.
%
%   ITRFMAP(...,SEL,PMM,TECPLATE,ID) reads high-resolution shape files
%   for land areas, rivers and borders (if available) with ID. The only
%   high-resolution data currently supported is ID='nweurope` and the
%   shapefiles must on the search path. Default (ID='none') is to use
%   low resolution maps that come with the Matlab mapping toolbox.
%
%   A short legend to the available arguments is:
%
%     Reference frames       Plate motion model (none/pmm) -----+
%       from ------------+                                      |
%       to ------+       |          Plot type (vel/pos) --+     |
%                |       |                                |     |
%                v       v                                v     v
%     itrfmap(refto, reffrom, epoch, latrange, lonrange, sel,  pmm, tecplate, id)
%
%   Supported reference frames are [ "ETRF2020"; "ETRF2014"; "ETRF2000"; 
%   "ITRF2020"; "ITRF2014"; "ITRF2008"; "ITRF2005"; "ITRF2000"; "ITRF97"; "ITRF96"; 
%   "ITRF94"; "ITRF93"; "ITRF92"; "ITRF91"; "ITRF90"; "ITRF89"; "ITRF88" ].
%
%   Supported plate motion models PMM are [ "none"; "NUVEL 1A NNR"; "ITRF2000"; 
%   "ITRF2008"; "ITRF2014"; "ITRF2020"; "GSRM 2.1 IGS08";  "GSRM 2.1 NNR" ].
%   The tectonic plate TECPLATE can be specified by it's full name, four-
%   and two character abbreviation. The supported plates depend on the 
%   plate motion model being used. Some of the possible values for TECPLATE
%   are [ "Africa"; "Antarctica"; "Arabia"; "Australia"; "Caribbean"; "Cocos"; 
%   "Eurasia"; "India"; "Nazca"; "NorthAmerica"; "Pacific"; "SouthAmerica" ]; 
%
%   Examples:
%
%     latrange=[35 68]; lonrange=[-12 35 ];     % Europe
%
%     itrfmap('ITRF2008', 'ETRF2000', 2010.0, latrange, lonrange)
%     itrfmap('ITRF2014', 'ETRF2000', 2018.0, latrange, lonrange, 'vel')
%     itrfmap('ITRF2020', 'ETRF2000', 2020.0, latrange, lonrange, 'vel', 'none')
%     itrfmap('ITRF2008', 'ETRF2000', 2020.0, latrange, lonrange, 'vel', 'GSRM 2.1 IGS08', 'Eurasia')
%
%     itrfmap('ITRF2020', 'ITRF2014', 2020.0, latrange, lonrange, 'vel', 'none')
%
%     itrfmap('ITRF2008', 'ETRF2020', 1989.0, latrange, lonrange, 'pos', 'none')
%     itrfmap('ITRF2008', 'ETRF2020', 2020.0, latrange, lonrange, 'pos', 'GSRM 2.1 IGS08', 'Eurasia')
%     itrfmap('ITRF2020', 'ETRF2020', 1989.0, latrange, lonrange, 'pos', 'none')
%     itrfmap('ITRF2020', 'ETRF2020', 2020.0, latrange, lonrange, 'pos', 'ITRF2020', 'Eurasia')
%
%     latrange=[50 54.5]; lonrange=[1.5 8.5 ];  % Netherlands 
%     addpath('d:\Surfdrive\Matlab\models\')    % Path to high resolution maps
%
%     itrfmap('ITRF2008', 'ETRF2000', 2020.0, latrange, lonrange, 'vel', 'GSRM 2.1 IGS08', 'Eurasia','nweurope')
%     itrfmap('ETRF2020', 'ETRF2014', 2020.0, latrange, lonrange, 'vel', 'none', 'none', 'nweurope')
%
%   See also ITRF2ITRF and PMMVEL.
%
%   Requires the Matlab mapping toolbox (if not available, should not be
%   too difficult to adjust the plotting part using coastlines only). 
%
%  (c) Hans van der Marel, Delft University of Technology, 2018-2025.

% Created:  9 February 2018 by Hans van der Marel
% Modified: 2 June 2025 by Hans van der Marel
%             - Major overhaul using itrf toolbox version 2 (with newly
%               added pmm functions and support for more TRF's)
%             - optional correction for plate motion (pmm)
%             - choice between plotting velocity differences and position
%               differences
%             - added option for low-resolution maps (useful when high
%               resolution shape files are unavailable)
%          14 July 2025 by Hans van der Marel
%             - single figure with subplots
%             - added extra argument for high resolution maps 
%             - added function help

tic

% Check arguments

if nargin < 9
   id='none';
   if nargin < 7
      pmm='none';
      if nargin < 6
         sel='vel';
      end
   end
end
if nargin < 5 || ( nargin == 7 && ~strcmpi(pmm,'none') )
   error('insufficient number of input arguments')
end

% Compute meshgrid

bbox = [ lonrange' latrange'];

%opt.interval=.1;                         % interpolation interval in deg
opt.interval= (ceil(lonrange(2))-floor(lonrange(1))+ceil(latrange(2))-floor(latrange(1)))/100;
tx=floor(bbox(1)):opt.interval:ceil(bbox(2));
ty=floor(bbox(3)):opt.interval:ceil(bbox(4));

[qx,qy]=meshgrid(tx,ty);

% Compute (nominal) velocity/position REFTO wrt to REFFROM

plh=[ qy(:)*pi/180 qx(:)*pi/180 zeros(size(qx(:)))];
xyz=plh2xyz(plh);

xyzitrf=itrf2itrf([xyz zeros(size(xyz)) ] ,char(reffrom),char(refto),refepoch);

posneuitrf=xyz2neu(xyzitrf(:,1:3)-xyz,xyz,'r');
velneuitrf=xyz2neu(xyzitrf(:,4:6),xyz,'r');

% Optionally correct for plate motion model (PMM) velocity

if ~strcmpi(pmm,'none')
   posneuitrf = posneuitrf - pmmvel(pmm,tecplate,plh) * ( refepoch - 1989.0);   %ETRS89 ref epoch
   velneuitrf = velneuitrf - pmmvel(pmm,tecplate,plh);
end

% Select plot type

if strncmpi(sel,'velocity',3)
   plttitle = [ 'Velocity{\Delta} ' char(refto) ' wrt ' char(reffrom) ];
   units='[mm/y]';
elseif strncmpi(sel,'position',3)
   velneuitrf=posneuitrf;
   plttitle = [ 'Coordinate{\Delta} ' char(refto) '@' num2str(refepoch,'%.1f') ' wrt ' char(reffrom) ];
   units='[mm]';
else
   error('Invalid selection, use vel or pos')
end
if ~strcmpi(pmm,'none')
    plttitle = [ plttitle ', pmm=' char(pmm)];
end

% Land areas, rivers and borders

if ~strcmpi(id,'none')
   try
      %id='nweurope';
      resolution='f';
      landareas = shaperead(['landareas_' id '_' resolution],'UseGeoCoords', true, 'BoundingBox', bbox);
      borders = shaperead(['borders_' id '_' resolution],'UseGeoCoords', true, 'BoundingBox', bbox);
      rivers = shaperead(['rivers_' id '_' resolution],'UseGeoCoords', true, 'BoundingBox', bbox);
      disp('Using high resolution land areas, rivers and borders.')
   catch
      disp('No high resolution land areas, rivers and borders available, maybe you did not set the path, using low resolution instead.')
      id='none';
   end
end
if strcmpi(id,'none')
   landareas = readgeotable("landareas.shp");
   rivers = readgeotable("worldrivers.shp");
   borders = geopoint();                       % empty 
end

% Plot four figures, with basemap and contour overlay of velocities or
% differences, in resp. North, East, Horizontal and Vertical direction

% Fig 1 - Plot the North velocity/difference

qz=reshape(velneuitrf(:,1)*1000,size(qx));
levels=getlevels(qz);

figure('position',[10,10,1000,800]);
t=tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact');
title(t,plttitle)

nexttile;
%figure;
ax=worldmap(latrange,lonrange);                         
setm(ax,'GLineStyle',':','GColor','k','FFaceColor','none'); % 'FFaceColor','cyan'
%[cs,h]=contourfm(qy,qx,qz,'LevelStep',levelstep,'LineColor',[0.6 0.6 0.6]);
try
   [cs,h]=contourfm(qy,qx,qz,levels,'LineColor',[0.6 0.6 0.6]);
   ht = clabelm(cs,h);
   set(ht,'Color','white','BackgroundColor','none','FontWeight','normal')
catch
   disp('Contourfm failure, skip...')
end
c=colorbar;
c.Label.String=units;
geoshow(landareas, 'FaceColor','none','EdgeColor','black'); 
geoshow(rivers, 'Color', 'cyan')
geoshow(borders, 'Color','black')
%title(['North ' plttitle])
title('North')

% Fig 2 - Plot the East velocity/difference

qz=reshape(velneuitrf(:,2)*1000,size(qx));
levels=getlevels(qz);

nexttile;
%figure;
ax=worldmap(latrange,lonrange);                         
setm(ax,'GLineStyle',':','GColor','k','FFaceColor','none'); % 'FFaceColor','cyan'
%[cs,h]=contourfm(qy,qx,qz,'LevelStep',levelstep,'LineColor',[0.6 0.6 0.6]);
try
   [cs,h]=contourfm(qy,qx,qz,levels,'LineColor',[0.6 0.6 0.6]);
   ht = clabelm(cs,h);
   set(ht,'Color','white','BackgroundColor','none','FontWeight','normal')
catch
   disp('Contourfm failure, skip...')
end
c=colorbar;
c.Label.String=units;
geoshow(landareas, 'FaceColor','none','EdgeColor','black'); 
geoshow(rivers, 'Color', 'cyan')
geoshow(borders, 'Color','black')
%title(['East ' plttitle])
title('East')

% Fig 3 - Plot the Horizontal velocity/difference

qz=reshape(sqrt(velneuitrf(:,1).^2+velneuitrf(:,2).^2)*1000,size(qx));
levels=getlevels(qz);

nexttile;
%figure;
ax=worldmap(latrange,lonrange);                         
setm(ax,'GLineStyle',':','GColor','k','FFaceColor','none'); % 'FFaceColor','cyan'
%[cs,h]=contourfm(qy,qx,qz,'LevelStep',levelstep,'LineColor',[0.6 0.6 0.6]);
try
   [cs,h]=contourfm(qy,qx,qz,levels,'LineColor',[0.6 0.6 0.6]);
   ht = clabelm(cs,h);
   set(ht,'Color','white','BackgroundColor','none','FontWeight','normal')
catch
   disp('Contourfm failure, skip...')
end
c=colorbar;
c.Label.String=units;
geoshow(landareas, 'FaceColor','none','EdgeColor','black'); 
geoshow(rivers, 'Color', 'cyan')
geoshow(borders, 'Color','black')

istep=6;
ix=floor(istep/2)+1:istep:size(qx,1);
iy=floor(istep/2)+1:istep:size(qx,2);
qxx=qx(ix,iy);
qyy=qy(ix,iy);
qzv=reshape(velneuitrf(:,1)*1000,size(qx));
qzu=reshape(velneuitrf(:,2)*1000,size(qx));
qzv=qzv(ix,iy);
qzu=qzu(ix,iy)./cosd(qyy);
hold on
quiverm(qyy(:),qxx(:),qzv(:),qzu(:),'r','filled')

%title(['Horizontal ' plttitle])
title('Horizontal')

% Fig 4 - Plot the Vertical velocity/difference

qz=reshape(velneuitrf(:,3)*1000,size(qx));
levels=getlevels(qz);

nexttile;
%figure;
ax=worldmap(latrange,lonrange);                         
setm(ax,'GLineStyle',':','GColor','k','FFaceColor','none'); % 'FFaceColor','cyan'
%[cs,h]=contourfm(qy,qx,qz,'LevelStep',levelstep,'LineColor',[0.6 0.6 0.6]);
try
   [cs,h]=contourfm(qy,qx,qz,levels,'LineColor',[0.6 0.6 0.6]);
   ht = clabelm(cs,h);
   set(ht,'Color','white','BackgroundColor','none','FontWeight','normal')
catch
   disp('Contourfm failure, skip...')
end
c=colorbar;
c.Label.String=units;
geoshow(landareas, 'FaceColor','none','EdgeColor','black'); 
geoshow(rivers, 'Color', 'cyan')
geoshow(borders, 'Color','black')
%title(['Vertical ' plttitle])
title('Vertical')

toc

end

function levels=getlevels(qz)

minz=min(qz(:));
maxz=max(qz(:));
zrange=maxz-minz;
if zrange < 0.01
   minz=minz-0.01/2;    
   maxz=maxz+0.01/2;    
   zrange=maxz-minz;
end
levelstep=10^(floor(log10(zrange)));
numlevels=ceil(zrange/levelstep);
%levelstep=levelstep/floor(10/numlevels);
while numlevels < 6
    levelstep=levelstep/2;
    numlevels=ceil(zrange/levelstep);
end
levelstep=max(levelstep,0.01);
levels=floor(minz/levelstep)*levelstep:levelstep:ceil(maxz/levelstep)*levelstep;
if length(levels) <1
    levels(1) = levels(1) - levelstep/2;
    levels(2) = levels(1) + levelstep;
end

end
