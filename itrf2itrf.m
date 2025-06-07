function crdout=itrf2itrf(crdin,from,to,yearin,yearout)
%ITRF2ITRF  Transform coordinates/velocities between various ITRF's.
%   CRD=ITRF2ITRF(CRD,FROM,TO,YEARIN,YEAROUT) convert coordinates and velocities
%   in CRD at epoch YEARIN from ITRF FROM to ITRF TO at epoch YEAROUT.
%
%   CRD=ITRF2ITRF(CRD,FROM,TO,YEARIN) convert coordinates and velocities
%   in CRD from ITRF FROM to ITRF TO at epoch YEARIN. CRD may in this case
%   also contain only coordinates.
%
%   See also ITRFTP and ITRFTPDEF.
%
%  (c) Hans van der Marel, Delft University of Technology.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 27 Feb 2014 by Hans van der Marel
%               - reduced possible shapes of crdin to prevent accidental mistakes

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

% Get the transformation parameters for the epoch of the input coordinates

[p,pdot]=itrftp(from,to,yearin);

% Do the transformation at the epoch of the input coordinates

if size(crdin,1) == 6
  crdout=trafo3d(crdin,p,pdot);
else
  crdout=trafo3d(crdin,p);
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