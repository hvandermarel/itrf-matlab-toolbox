function crdout=itrf2etrf(crdin,from,to,yearin,yearout)
%ITRF2ETRF  Transform coordinates/velocities between ITRFyy and ETRFyy.
%   CRD=ITRF2ETRF(CRD,FROM,TO,YEARIN,YEAROUT) convert coordinates and velocities
%   in CRD at epoch YEARIN. The input and output frame are given in FROM and TO
%   as a string ITRFyy or ETRFyy. YEAROUT is the output epoch.
%
%   CRD=ITRF2ETRF(CRD,FROM,TO,YEARIN) convert coordinates and velocities
%   in CRD from FROM to TO at epoch YEARIN. CRD may in this case also contain 
%   only coordinates (no velocity required).
%
%   This function can handle arrays of coordinates/velocities, with the 
%   triplets or sextets either stored as columns or rows (if crdin is 3x3 or 3x6
%   it is assumed that coordinate triplets are stored in columns, if crdin is
%   6x3 or 6x6 it is assumed that the coordinate/velocity sextets are stored
%   in columns).
%
%   Example
%
%       xdlft=[3924687.552; 301132.856; 5001910.904; -.0150; .0164; .0070];
%       xdlftetrs=itrf2etrf(xdlft,'ITRF2000','ETRF2000',1997,1989)
%       sprintf('%15.4f %15.4f %15.4f\n',xdlftetrs);       
%
%        3924687.7260     301132.7758    5001910.8000
%             -0.0020         -0.0006         -0.0022
%
%   References
%
%   [1] Claude Boucher and Zuheir Altamimi, Specifications for 
%       reference frame fixing in the analysis of a EUREF GPS campaign, 
%       Version 8.
%   [2] http://itrf.ensg.ign.fr/.
%
%   See also ITRF2ITRF and ETRFTPDEF.
%
%  (c) Hans van der Marel, Delft University of Technology.

%  Created:  18 December 2004 by Hans van der Marel
%  Modified: 24 March 2012 by Hans van der Marel
%               - Complete overhaul
%               - Use similar conventions to itrf2itrf
%            14 September 2012 by Hans van der Marel
%               - Added warning for dissimilar ITRF and ETRF's
%            27 Feb 2014 by Hans van der Marel
%               - reduced possible shapes of crdin to prevent accidental mistakes

% Get all ITRFyy to ETRFyy transformation parameters and save for future call's

persistent tpdef;
if isempty(tpdef) 
  tpdef=etrftpdef();
end

% Check the input arguments

if nargin ~= 4 && nargin ~= 5
  error('Incorrect number of input arguments.')
end

%transpose= ( size(crdin,1) ~=3 && size(crdin,1) ~=6  && ( size(crdin,2) == 3 || size(crdin,2) == 6 ) );
transpose= ( size(crdin,2) ~= 1 );
if transpose
  crdin=crdin';
end
if  size(crdin,1) ~=3 && size(crdin,1) ~=6 
  error('Vector with coordinates has not the right dimensions.')
end

if nargin == 4
  yearout=yearin;
end

if size(crdin,1) == 3 && abs(yearout-yearin) > 0.001
  error('Cannot convert coordinates to a different epoch without velocity information.')
end

% Get the transformation parameters 

from=upper(from);
to=upper(to);

if ismember(from(1:4),'ITRF','rows') && ismember(to(1:4),'ETRF','rows') 
  reverse=0;
elseif ismember(from(1:4),'ETRF','rows') && ismember(to(1:4),'ITRF','rows')
  reverse=1;
  tmp=from;
  from=to;
  to=tmp;
else
  error('This function only supports transformations between ITRFyy and ETRFyy, or vice versa')
end
if strcmp(from(5:end),to(5:end)) == 0
  error('This function only supports transformations between matching ITRFyy and ETRFyy')
end


[l,idxl]=ismember(to,tpdef.to,'rows');
p=tpdef.p(idxl,:);
if reverse
  p=-1.0*p;
end

% Do the transformation at the epoch of the input coordinates

p(1:3)=p(1:3)*1e-3;
p(4:6)=p(4:6)*1e-3*pi/(180*3600);

R=[ 0 -p(6) p(5) ; p(6) 0 -p(4) ; -p(5) p(4) 0 ];

crdout(1:3,:)=crdin(1:3,:) + repmat(p(1:3)',1,size(crdin,2)) + R * crdin(1:3,:) * ( yearin - 1989.0 );
if size(crdin,1) == 6
  crdout(4:6,:)=crdin(4:6,:) + R * crdin(1:3,:);
end

% Transform the coordinates to the output epoch

if abs(yearout-yearin) > 0.001
  crdout(1:3,:)=crdout(1:3,:)+crdout(4:6,:)*(yearout-yearin);
end

% Output must have same dimensions as input

if transpose
  crdout=crdout';
end

return

