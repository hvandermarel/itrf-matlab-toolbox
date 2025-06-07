function crdout=trafo3d(crdin,p,pdot)
%TRAFO3D   3D similarity transformation with 7 or 14 parameters.
%   CRD=TRAFO3D(CRD,P) does the following 3D simularity transformation
%
%     : XS :    : X :   : T1 :   :  D   -R3   R2 : : X :
%     :    :    :   :   :    :   :               : :   :
%     : YS :  = : Y : + : T2 : + :  R3   D   -R1 : : Y :
%     :    :    :   :   :    :   :               : :   :
%     : ZS :    : Z :   : T3 :   : -R2   R1   D  : : Z :
%
%   with P=[ T1 T2 T3 D R1 R2 R3 ] and CRD and array with X,Y,Z coordinates.
%   The units in P are mm, ppb and mas. The units in CRD are meters.
%
%   CRD=TRAFO3D(CRD,P,PDOT), with CRD consisting of coordinate/velocity
%   sexplets includes also the following 3D simularity transformation
%   for the velocity component
%       .         .       .         .    .    .
%     : XS :    : X :   : T1 :   :  D   -R3   R2 : : X :
%     : .  :    : . :   : .  :   :  .    .    .  : :   :
%     : YS :  = : Y : + : T2 : + :  R3   D   -R1 : : Y :
%     : .  :    : . :   : .  :   :  .    .    .  : :   :
%     : ZS :    : Z :   : T3 :   : -R2   R1   D  : : Z :
%
%   with velocities in m/s and the units for PDOT in mm/y, ppb/y and mas/y.
%
%   See also ITRFTP and ITRFTPDEF.
%
%  (c) Hans van der Marel, Delft University of Technology.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 

% Check the input arguments

if nargin ~= 2 && nargin ~= 3
  error('Incorrect number of input arguments.')
end

if size(p,2) == 1
  p=p';
end
if size(p,1) ~= 1 || size(p,2) ~= 7
  error('Vector with transformation parameters P has not the right dimensions.')
end

if nargin == 2
  if size(crdin,1) ~= 3 && size(crdin,2) ~=3
    error('Vector with coordinates has not the right dimensions.')
  end
  transpose=0;
  if size(crdin,1) ~=3
    transpose=1;
    crdin=crdin';
  end
elseif nargin == 3
  if size(crdin,1) ~= 6 && size(crdin,2) ~=6
    error('Vector with coordinates/velocities has not the right dimensions.')
  end
  transpose=0;
  if size(crdin,1) ~=6
    transpose=1;
    crdin=crdin';
  end
  if size(pdot,2) == 1
    pdot=pdot';
  end
  if size(pdot,1) ~= 1 || size(pdot,2) ~= 7
    error('Vector with transformation parameters PDOT has not the right dimensions.')
  end
end 

% Do the coordinate transformation

p(1:3)=p(1:3)*1e-3;
p(4)=p(4)*1e-9;
p(5:7)=p(5:7)*1e-3*pi/(180*3600);

R=[ p(4) -p(7) p(6) ; p(7) p(4) -p(5) ; -p(6) p(5) p(4) ];

crdout(1:3,:)=crdin(1:3,:) + repmat(p(1:3)',1,size(crdin,2)) + R*crdin(1:3,:);

% Do the velocity transformation

if size(crdin,1) == 6

  pdot(1:3)=pdot(1:3)*1e-3;
  pdot(4)=pdot(4)*1e-9;
  pdot(5:7)=pdot(5:7)*1e-3*pi/(180*3600);

  Rdot=[ pdot(4) -pdot(7) pdot(6) ; pdot(7) pdot(4) -pdot(5) ; -pdot(6) pdot(5) pdot(4) ];

  crdout(4:6,:)=crdin(4:6,:) + repmat(pdot(1:3)',1,size(crdin,2)) + Rdot*crdin(1:3,:);

end


if transpose
  crdout=crdout';
end

return
